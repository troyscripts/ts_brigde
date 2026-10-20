dofile('locales/nl.lua'); dofile('locale.lua'); dofile('server_config.lua')
local api, timers, requests, jsonObjects = {}, {}, {}, {}
local counter, owner, photo, screenshotState = 0, 'one', nil, 'stopped'
local function copy(x) if type(x)~='table' then return x end;local t={};for k,v in pairs(x)do t[k]=copy(v)end;return t end
json={encode=function(t) counter=counter+1;local key='json'..counter;jsonObjects[key]=copy(t);return key end,
 decode=function(k) if k=='rate' then return {retry_after=2} end;return copy(jsonObjects[k]) end}
exports=setmetatable({['screenshot-basic']={requestClientScreenshot=function(_,id,opts,cb) photo=cb end}}, {__call=function(_,n,f)api[n]=f end})
local events, handlers, capture = {}, {}, nil
function RegisterNetEvent(name, cb) events[name] = cb end
function AddEventHandler(name, cb) handlers[name] = cb end
function TriggerClientEvent(name, id, token)
    capture = { player = id, token = token }
    photo = function(err, data)
        source = id
        events['ts_bridge:screenshot:result'](token, data, err or nil)
    end
end
function GetInvokingResource() return owner end
function GetGameTimer() return 10000 end
function GetPlayerName() return 'Test' end
function GetResourceState() return screenshotState end
function SetTimeout(ms,f) timers[#timers+1]={ms=ms,f=f} end
function PerformHttpRequest(url,cb,method,body,headers)requests[#requests+1]={url=url,cb=cb,body=body,payload=copy(jsonObjects[body])}end
function GetCurrentResourceName() return 'ts_bridge' end
exports.ts_bridge = { UploadDiscordPhoto = function(_,url,payloadJson,dataUri,cb)
    requests[#requests+1]={url=url .. '?wait=true',cb=cb,imageData=dataUri,payload=copy(jsonObjects[payloadJson])}
end }
local a,b='https://discord.com/api/webhooks/1/a','https://discord.com/api/webhooks/2/b'
local payload={embeds={{title='Event',description='Original RP text',fields={{name='Player',value='Test'}}}}}
dofile('server/webhooks.lua')

dofile('audit_config.lua')
TSBridge.Audit('payments','AddMoney','test',{}, {ok=true})
assert(#requests==0, 'blank routes disabled')
for i, category in ipairs({'payments','societies','invoices','errors'}) do
 TSBridgeAuditConfig.Webhooks[category]='https://discord.com/api/webhooks/'..i..'/test'
end
for _, category in ipairs({'payments','societies','invoices'}) do
 TSBridge.Audit(category,'test','caller',{{'Bedrag',10}}, {ok=true,before=10,after=20})
end
assert(#requests==3)
TSBridge.Audit('payments','RemoveMoney','caller',{}, {ok=false,code='provider_error',uncertain=true})
assert(#requests==4 and requests[4].url:find('/4/test',1,true))
assert(#requests[4].payload.allowed_mentions.parse==0)
TSBridgeAuditConfig.Enabled=false
TSBridge.Audit('payments','test','caller',{}, {ok=true})
assert(#requests==4)
TSBridgeAuditConfig.Enabled=true
TSBridgeAuditConfig.Webhooks.payments='bad-url'
assert(pcall(TSBridge.Audit,'payments','test','caller',{}, {ok=true}))
assert(#requests==4)
print('PASS: audit routing, blank/disabled settings, error routing, mention suppression and invalid URL isolation')
