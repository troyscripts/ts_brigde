fx_version 'cerulean'
game 'gta5'
author 'Troy Scripts'
description 'Centrale ondersteuningsbridge voor Troy Scripts'
version '0.0.5'
shared_scripts { '@ox_lib/init.lua', 'locales/*.lua', 'locale.lua', 'config.lua', 'config_validation.lua', 'config_version.lua' }
client_scripts { 'client/main.lua', 'client/camera.lua', 'client/radial.lua', 'client/keycard_support.lua', 'client/alerts.lua', 'shared_status.lua' }
server_scripts { 'server_config.lua', 'server/validate.lua', 'server/framework.lua', 'server/money.lua', 'server/inventory.lua', 'server/billing.lua', 'server/main.lua', 'server/webhooks.lua', 'server/diagnostics.lua', 'server/updates.lua', 'server/update_check.lua', 'shared_status.lua' }
dependency 'ox_lib'
