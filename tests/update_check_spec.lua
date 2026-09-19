dofile('locales/nl.lua'); dofile('locale.lua')
local logs, timers, callback, requests, response, endpoint, headers = {}, {}, nil, 0, nil, nil, nil
local realPrint=print
function print(s) logs[#logs+1]=s end
function GetCurrentResourceName() return 'ts_bridge' end
function GetResourceMetadata() return '0.0.3' end
function Wait() end
function CreateThread(f) f() end
function SetTimeout(_,f) timers[#timers+1]=f end
function PerformHttpRequest(url,cb,method,body,h) requests=requests+1; endpoint=url;callback=cb;headers=h end
json={decode=function(body) if body=='bad' then error('invalid json') end; return response end}
local function reset(config)
 logs={}; timers={}; callback=nil; requests=0;TSBridgeServer={UpdateCheck=config}
 dofile('server/update_check.lua')
end
local function has(s) for _,l in ipairs(logs) do if l:find(s,1,true) then return true end end end
reset();assert(requests==1 and endpoint=='https://api.github.com/repos/troyscripts/ts_brigde/contents/version.json')
assert(headers.Accept=='application/vnd.github.raw+json')
response={version='0.0.4',download='https://evil.invalid'};callback(200,'ok');assert(has('Update beschikbaar') and has('Download: https://github.com/troyscripts/ts_brigde'))
assert(not has('evil'));local n=#logs;timers[1]();assert(#logs==n)
reset();response={version='0.0.3'};callback(200,'ok');assert(has('up-to-date'))
reset();response={version='0.0.2'};callback(200,'ok');assert(has('nieuwer'))
reset();response={version='0.0.4-beta'};callback(200,'ok');assert(has('geldige stabiele'))
reset();callback(404,'');assert(has('404'))
reset();callback(429,'');assert(has('429'))
reset();callback(200,'bad');assert(has('geldige stabiele'))
reset();callback(200,string.rep('x',16385));assert(has('te groot'))
reset();timers[1]();n=#logs;callback(200,'ok');assert(#logs==n and has('niet op tijd'))
reset({Enabled=false,Repository='troyscripts/ts_brigde'});assert(requests==0)
reset({Enabled=true,Repository='../bad'});assert(requests==0 and has('ongeldig'))
PerformHttpRequest=function() error('network unavailable') end
reset();assert(has('kon niet starten'))
realPrint('PASS: GitHub numeric comparison, default branch endpoint, safe link, disabled mode, timeout, malformed/oversized responses and HTTP failures')
