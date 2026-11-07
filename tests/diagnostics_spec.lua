-- Test publieke diagnose-API zonder geheime webhookgegevens.
local exportsApi, commands, output = {}, {}, {}
function exports(name, fn) exportsApi[name] = fn end
function RegisterCommand(name, fn) commands[name] = fn end
function GetCurrentResourceName() return 'ts_bridge' end
function GetResourceMetadata() return '1.1.7' end
function GetResourceState() return 'started' end
function print(value) output[#output + 1] = tostring(value) end
TSBridgeConfig = { TargetResource = 'ox_target' }
TSBridgeServer = {
    Framework = 'esx', ESXResource = 'es_extended', InventoryResource = 'ox_inventory',
    SocietyResource = 'esx_addonaccount', ScreenshotResource = 'screenshot-basic',
    Screenshots = true, Banking = { Provider = 'apex', Resource = 'apex_banking' },
    Billing = { Provider = 'none', Resource = '' }, UpdateCheck = { Enabled = true, Repository = 'troyscripts/ts_brigde' }
}
TSBridgeValidation = { valid = true, errors = {} }
TSBridgeWebhookStatus = function() return {
    queued = 0, capacity = 32, pendingPhotos = 0, destinations = 0,
    lastPhoto = 'geen', lastDelivery = 'geen', lastFailure = 'geen',
    deliveries = { confirmed = 3, failed = 1, unconfirmed = 0, rateLimited = 2, photoFallbacks = 1 },
    configuredRoutes = { ts_keycard = {issue=true, transfer=true}, ts_nlplates = {created=true} },
    auditRoutes = {errors=true}
} end
TSL = function(key) return key end
dofile('server/core/diagnostics.lua')
local d = exportsApi.GetDiagnostics()
assert(d.webhooks.deliveries.confirmed == 3)
assert(d.webhooks.configuredRoutes.ts_keycard.issue == true)
commands.ts_bridge_check(0)
local all = table.concat(output, '\n')
assert(all:find('bevestigd=3', 1, true))
assert(all:find('ts_keycard: issue, transfer', 1, true))
assert(all:find('Auditwebhooks: errors', 1, true))
assert(not all:find('https://', 1, true), 'webhook URL leaked')
assert(not all:find('TOKEN', 1, true), 'webhook token leaked')
output = {}
commands.ts_bridge_check(1)
assert(#output == 0, 'console-only command accessible to player')
print('PASS webhook diagnostic counters/routes and no URL leaks')
