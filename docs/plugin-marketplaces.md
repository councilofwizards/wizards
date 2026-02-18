# Plugin Marketplaces

## What This Project Is

This repo (`councilofwizards/wizards`) is a Claude Code **plugin marketplace** — a git repository with a specific structure that Claude Code natively understands. Friends and collaborators add it with a single command and pick which plugins to enable. No install scripts, no website, no external tooling. Everything happens inside Claude Code via `/plugin`.

```
/plugin marketplace add councilofwizards/wizards
/plugin install review-plugin@wizards
```

## How Claude Code Marketplaces Work

A marketplace is a git repo containing:

1. `.claude-plugin/marketplace.json` — the catalog listing all available plugins
2. One or more plugin directories, each with its own `.claude-plugin/plugin.json` manifest
3. The actual plugin content: skills, commands, agents, hooks, MCP servers, LSP servers

Users interact entirely through Claude Code's built-in `/plugin` commands:

| Command | What It Does |
|---------|-------------|
| `/plugin marketplace add owner/repo` | Add a marketplace from GitHub |
| `/plugin marketplace add https://gitlab.com/org/repo.git` | Add from any git host |
| `/plugin marketplace add ./local-path` | Add a local marketplace for testing |
| `/plugin marketplace update` | Pull latest changes from all marketplaces |
| `/plugin install name@marketplace` | Install a specific plugin |
| `/plugin validate .` | Validate marketplace and plugin structure |

## Repository Structure

```
wizards/
  .claude-plugin/
    marketplace.json          # The marketplace catalog
  plugins/
    review-plugin/
      .claude-plugin/
        plugin.json           # Plugin manifest
      skills/
        review/
          SKILL.md            # A /review skill
    deploy-tools/
      .claude-plugin/
        plugin.json
      commands/
        deploy.md
      agents/
        deploy-reviewer.md
      hooks.json
      mcp-servers.json
```

## Marketplace Manifest

The file `.claude-plugin/marketplace.json` is the catalog. It lists every plugin in the marketplace and where to find it.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Marketplace identifier (kebab-case). Users see this: `plugin-name@this-name` |
| `owner` | object | Maintainer info: `name` (required), `email` (optional) |
| `plugins` | array | List of available plugins |

### Optional Metadata

| Field | Type | Description |
|-------|------|-------------|
| `metadata.description` | string | Brief marketplace description |
| `metadata.version` | string | Marketplace version |
| `metadata.pluginRoot` | string | Base directory for relative plugin paths (e.g. `"./plugins"`) |

### Example

```json
{
  "name": "wizards",
  "owner": {
    "name": "Zachary Mowrey"
  },
  "metadata": {
    "description": "Curated Claude Code plugins for power users",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "review-plugin",
      "source": "./plugins/review-plugin",
      "description": "Adds a /review skill for quick code reviews"
    },
    {
      "name": "deploy-tools",
      "source": "./plugins/deploy-tools",
      "description": "Deployment automation commands and agents"
    }
  ]
}
```

### Reserved Names

These marketplace names are reserved by Anthropic and cannot be used: `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `life-sciences`. Names that impersonate official marketplaces are also blocked.

## Plugin Manifests

Each plugin has `.claude-plugin/plugin.json`:

```json
{
  "name": "review-plugin",
  "description": "Adds a /review skill for quick code reviews",
  "version": "1.0.0"
}
```

## Plugin Sources

Plugins can live in the same repo (relative paths) or reference external repos.

### Relative paths (plugins in this repo)

```json
{ "name": "my-plugin", "source": "./plugins/my-plugin" }
```

Works when users add the marketplace via git (which is the standard flow).

### GitHub repos (plugins hosted elsewhere)

```json
{
  "name": "external-plugin",
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo",
    "ref": "v2.0.0",
    "sha": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0"
  }
}
```

### Any git URL

```json
{
  "name": "gitlab-plugin",
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git"
  }
}
```

## What Plugins Can Contain

A single plugin can bundle any combination of:

### Skills

Markdown files with frontmatter. The primary way to add new `/slash-commands`:

```markdown
# plugins/review-plugin/skills/review/SKILL.md
---
description: Review code for bugs, security, and performance
disable-model-invocation: true
---

Review the code I've selected or the recent changes for:
- Potential bugs or edge cases
- Security concerns
- Performance issues
- Readability improvements

Be concise and actionable.
```

### Commands, Agents, Hooks, MCP Servers, LSP Servers

These are declared either in the plugin's `plugin.json` or in the marketplace entry itself. Paths are relative to the plugin root. Use `${CLAUDE_PLUGIN_ROOT}` to reference files within the installed plugin directory (plugins are copied to a cache location on install).

```json
{
  "name": "enterprise-tools",
  "source": { "source": "github", "repo": "company/enterprise-plugin" },
  "commands": ["./commands/core/", "./commands/enterprise/"],
  "agents": ["./agents/security-reviewer.md"],
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
      }]
    }]
  },
  "mcpServers": {
    "enterprise-db": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  }
}
```

### strict vs non-strict plugins

By default, `strict: true` — marketplace entry fields merge with the plugin's own `plugin.json`. Set `strict: false` on a marketplace entry to define the plugin entirely from the marketplace catalog (no `plugin.json` needed in the plugin directory).

## Distribution

### For friends and collaborators (our use case)

1. Push this repo to `councilofwizards/wizards` on GitHub
2. Tell people to run: `/plugin marketplace add councilofwizards/wizards`
3. They browse available plugins and install what they want
4. Updates: `/plugin marketplace update` pulls latest

### Auto-prompting teammates

Add the marketplace to a project's `.claude/settings.json` so team members are prompted to install it when they trust the project:

```json
{
  "extraKnownMarketplaces": {
    "wizards": {
      "source": {
        "source": "github",
        "repo": "councilofwizards/wizards"
      }
    }
  }
}
```

Pre-enable specific plugins:

```json
{
  "enabledPlugins": {
    "review-plugin@wizards": true,
    "deploy-tools@wizards": true
  }
}
```

### Private repos

Claude Code uses existing git credentials. If `git clone` works in your terminal, it works for marketplaces. For background auto-updates, set `GITHUB_TOKEN` in your shell config.

## Important Caveats

- **Plugins are copied to a cache location on install.** They cannot reference files outside their own directory using `../` paths. Use symlinks (followed during copy) or keep shared files inside the plugin directory.
- **`${CLAUDE_PLUGIN_ROOT}`** is required in hooks and MCP server configs to reference plugin files, since the install path is not the repo path.
- **MCP servers and hooks run arbitrary code.** Trust the source.
- **Secrets should never be committed.** Use environment variables.

## Validation

Before pushing changes, validate the marketplace:

```bash
claude plugin validate .
```

Or from within Claude Code:

```
/plugin validate .
```

## References

- [Plugin Marketplaces docs](https://code.claude.com/docs/en/plugin-marketplaces) — creating and distributing marketplaces
- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) — the user-facing install flow
- [Plugins](https://code.claude.com/docs/en/plugins) — creating individual plugins
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) — full schema and technical details
- [Plugin settings](https://code.claude.com/docs/en/settings#plugin-settings) — configuration options
