<?php

namespace App\Commands;

use App\Repositories\LocalConfigRepository;

class ConfigSetCommand extends Command
{
    /**
     * The signature of the command.
     *
     * @var string
     */
    protected $signature = 'config:set
        {name : Environment name (e.g., production, staging)}
        {server? : Server ID}
        {site? : Site ID}
        {--confirm : Require confirmation before deploying}
        {--no-confirm : Disable confirmation requirement}';

    /**
     * The description of the command.
     *
     * @var string
     */
    protected $description = 'Add or update an environment in the .forge config';

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $name = strtolower($this->argument('name'));
        $serverId = $this->argument('server');
        $siteId = $this->argument('site');

        $config = $this->localConfig->all();

        // Determine if we're updating or creating
        $isUpdate = isset($config['environments'][$name]) ||
                    (!isset($config['environments']) && !empty($config['server']));

        // Get existing environment config if updating
        $envConfig = $config['environments'][$name] ?? [];

        // Update server if provided
        if ($serverId) {
            $envConfig['server'] = (int) $serverId;
        }

        // Update site if provided
        if ($siteId) {
            $envConfig['site'] = (int) $siteId;
        }

        // Handle confirm flag
        if ($this->option('confirm')) {
            $envConfig['confirm'] = true;
        } elseif ($this->option('no-confirm')) {
            unset($envConfig['confirm']);
        }

        // Validate we have at least a server
        if (empty($envConfig['server']) && !$serverId) {
            $this->error('Server ID is required. Usage: forge config:set <name> <server-id> [site-id]');
            return 1;
        }

        // Build new config structure
        if (!isset($config['environments'])) {
            // Convert simple config to environment-based or create fresh
            $newConfig = [
                'default' => $name,
                'environments' => [
                    $name => $envConfig,
                ],
            ];

            // If there was an existing simple config, preserve it as 'default' or migrate
            if (!empty($config['server'])) {
                // Ask if they want to migrate existing config
                $existingName = $this->askStep('Existing simple config found. Name for it?', 'legacy');
                if ($existingName && $existingName !== $name) {
                    $newConfig['environments'][$existingName] = [
                        'server' => $config['server'],
                        'site' => $config['site'] ?? null,
                        'confirm' => $config['confirm'] ?? false,
                    ];
                }
            }

            $config = $newConfig;
        } else {
            // Update existing environments config
            $config['environments'][$name] = $envConfig;

            // If this is the first environment, set it as default
            if (empty($config['default'])) {
                $config['default'] = $name;
            }
        }

        // Clean up null values
        if (isset($config['environments'][$name]['site']) && $config['environments'][$name]['site'] === null) {
            unset($config['environments'][$name]['site']);
        }

        // Write config
        $this->localConfig->create(getcwd(), $config);

        $action = $isUpdate ? 'Updated' : 'Added';
        $this->successfulStep(["{$action} environment: %s", $name]);

        // Show summary
        $env = $config['environments'][$name];
        $this->line('');
        $this->line("  <comment>Server:</comment>  {$env['server']}");
        if (isset($env['site'])) {
            $this->line("  <comment>Site:</comment>    {$env['site']}");
        }
        $this->line('  <comment>Confirm:</comment> ' . (!empty($env['confirm']) ? 'yes' : 'no'));

        return 0;
    }
}
