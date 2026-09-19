dofile('locales/nl.lua'); dofile('locale.lua'); dofile('server_config.lua')
local api, timers, requests, jsonObjects = {}, {}, {}, {}
local counter, owner, photo, screenshotState = 0, 'one', nil, 'stopped'
local function copy(x) if type(x)~='table' then return x end;local t={};for k,v in pairs(x)do t[k]=copy(v)end;return t end
json={encode=function(t) counter=counter+1;local key='json'..counter;jsonObjects[key]=copy(t);return key end,
 decode=function(k) if k=='rate' then return {retry_after=2} end;return copy(jsonObjects[k]) end}
exports=setmetatable({['screenshot-basic']={requestClientScreenshot=function(_,id,opts,cb) photo=cb end}}, {__call=function(_,n,f)api[n]=f end})
function GetInvokingResource() return owner end
function GetGameTimer() return 10000 end
function GetPlayerName() return 'Test' end
function GetResourceState() return screenshotState end
function SetTimeout(ms,f) timers[#timers+1]={ms=ms,f=f} end
function PerformHttpRequest(url,cb,method,body,headers)requests[#requests+1]={url=url,cb=cb,body=body,payload=copy(jsonObjects[body])}end
local a,b='https://discord.com/api/webhooks/1/a','https://discord.com/api/webhooks/2/b'
local payload={embeds={{title='Event',description='Original RP text',fields={{name='Player',value='Test'}}}}}
dofile('server/webhooks.lua')
assert(api.SendWebhook('start',a,payload));assert(api.SendWebhook('start',b,payload))
assert(#requests==2, 'a hung destination must not block another')
requests[1].cb(429,'rate');local retry=timers[#timers]
assert(api.SendWebhook('start',a,payload)); assert(#requests==2, 'same endpoint stays ordered')
requests[2].cb(204,'');timers[#timers].f()
assert(api.SendWebhook('start',b,payload));assert(#requests==3, 'other destination continues during backoff')
retry.f();assert(#requests==4 and requests[4].url==a)
assert(api.GetWebhookStatus().queued==3)
requests[4].cb(204,'');timers[#timers].f();assert(#requests==5 and requests[5].url==a)
-- Fresh isolated state: screenshot failure retains original content and caller input.
requests={};timers={};dofile('server/webhooks.lua')
assert(api.SendWebhook('start',a,payload,{screenshot=true,playerId=1}))
assert(requests[1].payload.embeds[1].description=='Original RP text')
assert(#requests[1].payload.embeds[1].fields==2 and #payload.embeds[1].fields==1)
requests[1].cb(204,'');timers[#timers].f()
screenshotState='started';TSBridgeServer.MaxQueue=1
assert(api.SendWebhook('start',a,payload,{screenshot=true,playerId=1}))
assert(api.GetWebhookStatus().pendingPhotos==1)
assert(not api.SendWebhook('start',b,payload), 'pending photo reserves total capacity')
local timeout=timers[#timers];assert(timeout.ms==8000);timeout.f()
assert(#requests==2 and requests[2].payload.embeds[1].description=='Original RP text')
assert(api.GetWebhookStatus().queued==1 and api.GetWebhookStatus().pendingPhotos==0)
photo(false,'data:image/jpeg;base64,/9j/');assert(#requests==2, 'late callback ignored')
requests[2].cb(204,'');timers[#timers].f();assert(api.GetWebhookStatus().queued==0)
local full=copy(payload);full.embeds[1].fields={};for i=1,25 do full.embeds[1].fields[i]={name='n',value='v'}end
screenshotState='stopped';assert(api.SendWebhook('start',a,full,{screenshot=true,playerId=1}))
assert(#requests[3].payload.embeds[1].fields==25 and requests[3].payload.content:find('Screenshot'))
print('PASS: independent webhook lanes, same-destination order/backoff, capacity reservations, description preservation, full embed fallback, late callback')
