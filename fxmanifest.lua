fx_version 'cerulean'
game 'gta5'
author 'Troy Scripts'
description 'Centrale ondersteuningsbridge voor Troy Scripts'
version '1.1.8'
shared_scripts {
    '@ox_lib/init.lua',
    'locales/locale.lua',
    'locales/nl.lua',
    'locales/en.lua',
    'config/config.lua',
    'shared/config_validation.lua',
    'shared/config_version.lua',
    'shared/vehicle_plates.lua'
}
client_scripts {
    'client/core/screenshots.lua',
    'client/core/main.lua',
    'client/core/camera.lua',
    'client/core/radial.lua',
    'client/core/radial_actions.lua',
    'client/integrations/keycard_support.lua',
    'client/integrations/jobcards.lua',
    'client/integrations/vehicles.lua',
    'client/core/alerts.lua',
    'shared_status.lua' -- compatibel met bestaande cross-resource tests
}
server_scripts {
    'config/webhook_config.lua',
    'server/core/validate.lua',
    'server/core/framework.lua',
    'server/core/money.lua',
    'server/core/inventory.lua',
    'server/integrations/vehicles.lua',
    'server/core/billing.lua',
    'server/core/main.lua',
    'server/integrations/jobcards.lua',
    'server/uploads/screenshot_upload.js',
    'server/services/webhooks.lua',
    'server/core/diagnostics.lua',
    'server/services/updates.lua',
    'server/services/update_check.lua',
    'shared_status.lua'
}
dependency 'ox_lib'

ui_page 'web/alerts.html'
files { 'web/alerts.html', 'web/alerts.css', 'web/alerts.js' }


