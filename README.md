<p align="center">
    <img src="/art/readme.png" alt="Logo Laravel Forge CLI preview" style="width:70%;">
</p>

## Introduction

[Laravel Forge](https://forge.laravel.com) is a server management and site deployment service. This is a **fork** of the official [Laravel Forge CLI](https://github.com/laravel/forge-cli) with added support for **project-local configuration files** and **named environments**.

### What's New In This Fork

- **Local `.forge` config files** - Configure server/site per project directory
- **Named environments** - Define `production`, `staging`, `dev` etc. with different server/site combinations
- **Deployment safety** - Confirmation prompts before deploying to protected environments
- **Smart detection** - `forge deploy staging` automatically detects if "staging" is an environment or site name
- **Config management commands** - Easily manage your `.forge` config from the CLI

## Installation

### From Source (Recommended for Development)

```bash
# Clone the repository
git clone git@github.com:Blue-Badger-Team/forge-cli.git
cd forge-cli

# Install dependencies
composer install

# Add alias to your shell config (~/.bashrc or ~/.zshrc)
alias forge="php /path/to/forge-cli/forge"

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

### Authentication

```bash
# Login with your Forge API token
forge login

# Or set via environment variable
export FORGE_API_TOKEN=your-token-here
```

## Project-Local Configuration

The main feature of this fork is the ability to create a `.forge` config file in your project directory. This eliminates the need to specify server/site on every command.

### Quick Setup

```bash
cd /path/to/your/project

# Interactive setup (recommended)
forge init

# Or quick setup with config commands
forge config:set production 123456 789012 --confirm
forge config:set staging 123456 789013
forge config:default staging
```

### Configuration Format

The `.forge` file supports two formats:

#### Simple Format (Single Environment)

```json
{
  "server": 123456,
  "site": 789012,
  "confirm": true
}
```

#### Named Environments (Recommended)

```json
{
  "default": "staging",
  "environments": {
    "production": {
      "server": 123456,
      "site": 789012,
      "confirm": true
    },
    "staging": {
      "server": 123456,
      "site": 789013
    },
    "dev": {
      "server": 111111,
      "site": 222222
    }
  }
}
```

### Configuration Options

| Key | Description |
|-----|-------------|
| `server` | Forge Server ID |
| `site` | Forge Site ID |
| `confirm` | If `true`, requires confirmation before deploying |
| `default` | Default environment name to use |
| `environments` | Named environment configurations |

### Finding Your Server/Site IDs

```bash
# List all servers (shows IDs)
forge server:list

# Switch to a server and list its sites
forge server:switch
forge site:list
```

## Commands

### Deployment

```bash
# Deploy to default environment
forge deploy

# Deploy to specific environment
forge deploy staging
forge deploy production

# Deploy with explicit site (bypasses .forge config)
forge deploy --site=mysite.com

# Skip confirmation prompt (for CI/CD)
forge deploy production --force
```

**Smart Detection:** When you run `forge deploy staging`, the CLI checks:
1. Is "staging" a configured environment? → Use it
2. Otherwise → Treat "staging" as a site name

### Configuration Management

```bash
# Show current config
forge config

# Add/update an environment
forge config:set <name> <server-id> <site-id>
forge config:set production 123456 789012 --confirm
forge config:set staging 123456 789013

# Toggle confirmation requirement
forge config:set production --confirm
forge config:set staging --no-confirm

# Set default environment
forge config:default staging

# Remove an environment
forge config:remove dev
```

### Interactive Setup

```bash
# Full interactive setup with named environments
forge init

# Simple setup (single server/site)
forge init --simple

# Overwrite existing config
forge init --force
```

## Deployment Safety

Environments with `"confirm": true` will prompt before deploying:

```
$ forge deploy production

  WARNING: You are about to deploy to PRODUCTION

‣ Are You Sure You Want To Deploy To PRODUCTION? (yes/no) [no]:
```

To bypass in CI/CD pipelines:
```bash
forge deploy production --force
```

### Recommended Setup

1. Set `staging` or `dev` as the default environment
2. Enable `confirm: true` on `production`
3. Use `forge deploy` for quick staging deploys
4. Use `forge deploy production` (with confirmation) for production

## Example Workflow

```bash
# Initial setup (one time)
cd ~/projects/my-app
forge init
# Follow prompts to configure production + staging

# Daily workflow
forge deploy              # Deploys to staging (default)
forge deploy production   # Prompts for confirmation, then deploys

# CI/CD pipeline
forge deploy staging --force
```

## Config File Location

The CLI searches for `.forge` starting from the current directory and walking up to parent directories (similar to `.gitignore`). This means you can:

- Place `.forge` in your project root
- Place `.forge` in a parent directory to share config across multiple projects
- Override parent config by placing `.forge` in a subdirectory

## All Available Commands

### New Commands (This Fork)

| Command | Description |
|---------|-------------|
| `forge init` | Interactive setup for `.forge` config |
| `forge config` | Display current configuration |
| `forge config:set` | Add or update an environment |
| `forge config:remove` | Remove an environment |
| `forge config:default` | Set the default environment |

### Standard Forge CLI Commands

| Command | Description |
|---------|-------------|
| `forge login` | Authenticate with Laravel Forge |
| `forge logout` | Logout from Laravel Forge |
| `forge deploy` | Deploy a site |
| `forge ssh` | Start an SSH session |
| `forge tinker` | Tinker with a site |
| `forge server:list` | List all servers |
| `forge server:switch` | Switch to a different server |
| `forge site:list` | List sites on current server |
| `forge site:logs` | View site logs |
| `forge env:pull` | Download environment file |
| `forge env:push` | Upload environment file |
| `forge daemon:list` | List daemons |
| `forge nginx:logs` | View Nginx logs |
| `forge php:logs` | View PHP logs |
| `forge database:shell` | Open database shell |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `FORGE_API_TOKEN` | API token (alternative to `forge login`) |
| `FORGE_API_BASE` | Custom API endpoint (default: `https://forge.laravel.com/api/v1/`) |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

- Original [Laravel Forge CLI](https://github.com/laravel/forge-cli) by Laravel
- Local environment config feature by Blue Badger Team

## License

Forge CLI is open-sourced software licensed under the [MIT license](LICENSE.md).
