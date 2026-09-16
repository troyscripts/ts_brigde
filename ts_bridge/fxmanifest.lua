fx_version 'cerulean'
game 'gta5'
author 'Troy Scripts'
description 'Centrale ondersteuningsbridge voor Troy Scripts'
version '0.0.1(BETA)'
shared_scripts { '@ox_lib/init.lua', 'config.lua' }
client_scripts { 'client/main.lua', 'client/keycard_support.lua', 'client/alerts.lua' }
server_scripts { 'server_config.lua', 'server/framework.lua', 'server/money.lua', 'server/inventory.lua', 'server/billing.lua', 'server/main.lua', 'server/webhooks.lua' }
dependency 'ox_lib'
