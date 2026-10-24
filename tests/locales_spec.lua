-- Load shared scripts in manifest order, just as FiveM does (skip external ox_lib).
exports = function() end
function IsDuplicityVersion() return false end
function GetCurrentResourceName() return 'ts_bridge' end
local f = assert(io.open('fxmanifest.lua')); local manifest = f:read('*a'); f:close()
local shared = assert(manifest:match('shared_scripts%s*(%b{})'))
for path in shared:gmatch("'([^']+)'") do
    if path:sub(1, 1) ~= '@' then assert(loadfile(path))() end
end
assert(TSBridgeValidation.valid)
assert(TSBridgeConfig.Locale == 'nl')
local function placeholders(text)
    local out = {}
    for token in text:gmatch('%%[%d%.%-]*[sdif]') do out[#out + 1] = token end
    return table.concat(out, ',')
end
for key, value in pairs(Locales.nl) do
    assert(type(Locales.en[key]) == 'string', 'Missing English: ' .. key)
    assert(placeholders(value) == placeholders(Locales.en[key]), 'Format mismatch: ' .. key)
end
for key in pairs(Locales.en) do assert(Locales.nl[key], 'Missing Dutch: ' .. key) end
TSBridgeConfig.Locale = 'en'
assert(TSL('alerts_politiemelding') == 'Police alert')
assert(TSL('alerts_postcode', '001') == 'Nearest postcode: 001')
local saved = Locales.en.alerts_accept
Locales.en.alerts_accept = nil
assert(TSL('alerts_accept') == Locales.nl.alerts_accept)
Locales.en.alerts_accept = saved
TSBridgeConfig.Locale = 'missing'
assert(TSL('alerts_politiemelding') == Locales.nl.alerts_politiemelding)
assert(TSL('missing_key') == 'missing_key')
-- Test the actual English diagnostic output through its registered command.
TSBridgeConfig.Locale = 'en'
local command, output = nil, {}
function RegisterCommand(_, callback) command = callback end
function GetResourceMetadata() return '1.0.7' end
function GetResourceState() return 'started' end
TSBridgeWebhookStatus = function() return {queued=0, capacity=32, pendingPhotos=0, destinations=0} end
local originalPrint = print
print = function(line) output[#output + 1] = line end
dofile('server/diagnostics.lua')
command(0)
print = originalPrint
assert(table.concat(output, '\n'):find('Last screenshot: unknown', 1, true))
assert(table.concat(output, '\n'):find('GitHub configured: true', 1, true))
print('PASS: manifest load order, English/Dutch parity, format tokens, fallback and English diagnostics')
