#compdef forge

# Forge CLI Zsh Completion
# Install: Add to ~/.zshrc:
#   source /path/to/forge-cli/completions/forge.zsh

_forge_get_environments() {
    local forge_file=""
    local dir="$PWD"

    # Walk up to find .forge file
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.forge" ]]; then
            forge_file="$dir/.forge"
            break
        fi
        dir="$(dirname "$dir")"
    done

    if [[ -n "$forge_file" ]]; then
        # Extract environment names from .forge JSON
        grep -o '"[^"]*":.*{' "$forge_file" 2>/dev/null | \
            grep -v '"environments"' | \
            grep -v '"default"' | \
            sed 's/"//g' | sed 's/:.*{//' | tr '\n' ' '
    fi
}

_forge() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a commands
    commands=(
        'deploy:Deploy a site'
        'init:Initialize a .forge config file'
        'config:Display the local .forge configuration'
        'config\:set:Add or update an environment'
        'config\:remove:Remove an environment'
        'config\:default:Set the default environment'
        'login:Authenticate with Laravel Forge'
        'logout:Logout from Laravel Forge'
        'ssh:Start an SSH session'
        'tinker:Tinker with a site'
        'open:Open a site in forge.laravel.com'
        'server\:list:List the servers'
        'server\:switch:Switch to a different server'
        'server\:current:Determine your current server'
        'site\:list:List the sites'
        'site\:logs:Retrieve the latest site log messages'
        'env\:pull:Download the environment file'
        'env\:push:Upload the environment file'
        'deploy\:logs:Retrieve deployment log messages'
        'daemon\:list:List the daemons'
        'daemon\:logs:Retrieve daemon log messages'
        'daemon\:restart:Restart a daemon'
        'daemon\:status:Get daemon status'
        'database\:logs:Retrieve database log messages'
        'database\:restart:Restart the database'
        'database\:shell:Start a database shell'
        'database\:status:Get database status'
        'nginx\:logs:Retrieve Nginx log messages'
        'nginx\:restart:Restart Nginx'
        'nginx\:status:Get Nginx status'
        'php\:logs:Retrieve PHP log messages'
        'php\:restart:Restart PHP'
        'php\:status:Get PHP status'
        'ssh\:configure:Configure SSH key authentication'
        'ssh\:test:Test SSH key authentication'
    )

    _arguments -C \
        '1: :->command' \
        '*: :->args' \
        && return 0

    case $state in
        command)
            _describe -t commands 'forge commands' commands
            ;;
        args)
            case $words[2] in
                deploy)
                    local environments
                    environments=($(_forge_get_environments))

                    _arguments \
                        '1:environment or site:->target' \
                        '--site=[Explicit site name]:site:' \
                        '--force[Skip confirmation prompt]' \
                        '--help[Display help]'

                    if [[ $state == target ]]; then
                        if [[ -n "$environments" ]]; then
                            _values 'environment' $environments
                        fi
                    fi
                    ;;
                init)
                    _arguments \
                        '--force[Overwrite existing .forge file]' \
                        '--simple[Create simple config without environments]' \
                        '--help[Display help]'
                    ;;
                config)
                    _arguments '--help[Display help]'
                    ;;
                config:set)
                    local environments
                    environments=($(_forge_get_environments))

                    _arguments \
                        '1:environment name:->envname' \
                        '2:server ID:' \
                        '3:site ID:' \
                        '--confirm[Require confirmation]' \
                        '--no-confirm[Disable confirmation]' \
                        '--help[Display help]'

                    if [[ $state == envname && -n "$environments" ]]; then
                        _values 'environment' $environments 'production' 'staging' 'dev'
                    fi
                    ;;
                config:remove)
                    local environments
                    environments=($(_forge_get_environments))

                    _arguments \
                        '1:environment name:->envname' \
                        '--force[Skip confirmation]' \
                        '--help[Display help]'

                    if [[ $state == envname && -n "$environments" ]]; then
                        _values 'environment' $environments
                    fi
                    ;;
                config:default)
                    local environments
                    environments=($(_forge_get_environments))

                    _arguments \
                        '1:environment name:->envname' \
                        '--help[Display help]'

                    if [[ $state == envname && -n "$environments" ]]; then
                        _values 'environment' $environments
                    fi
                    ;;
                ssh)
                    _arguments \
                        '1:server:' \
                        '-u[SSH user]:user:' \
                        '--user=[SSH user]:user:' \
                        '--help[Display help]'
                    ;;
                server:switch)
                    _arguments \
                        '1:server:' \
                        '--help[Display help]'
                    ;;
                env:pull|env:push)
                    _arguments \
                        '1:site:' \
                        '2:file:_files' \
                        '--help[Display help]'
                    ;;
                site:logs)
                    _arguments \
                        '1:site:' \
                        '--follow[Tail the logs]' \
                        '--help[Display help]'
                    ;;
                *)
                    _arguments '--help[Display help]'
                    ;;
            esac
            ;;
    esac
}

_forge "$@"
