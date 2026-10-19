local event, shot, active, sent, restored = nil,nil,nil,{},0
local timers, threads, stops = {},{},{}
local speed, exists = 0,true
function AddEventHandler(n,fn)stops[n]=fn end
function RegisterNetEvent(_,fn)event=fn end
function GetResourceState()return 'started'end
function SetTimeout(_,fn)timers[#timers+1]=fn end
function CreateThread(fn)threads[#threads+1]=fn end
function Wait()end
function TriggerServerEvent(_,token,_,reason)sent[#sent+1]={token=token,reason=reason}end
function TriggerLatentServerEvent(_,_,token,data)sent[#sent+1]={token=token,data=data}end
function GetRenderingCam()return active end
function RenderScriptCams(v)if not v then active=nil;restored=restored+1 end end
function DoesCamExist()return true end
function DestroyCam()end
function GetCurrentResourceName()return 'ts_bridge'end
function NetworkGetEntityFromNetworkId()return 42 end
function PlayerPedId()return 1 end
function DoesEntityExist()return exists end
function GetEntityType()return 2 end
function IsEntityDead()return false end
function GetEntitySpeed()return speed end
local vec={__sub=function()return setmetatable({}, {__len=function()return 2 end})end}
function GetEntityCoords()return setmetatable({},vec)end
function GetVehicleNumberPlateText()return 'A 123 BC' end
function IsGameplayCamRendering()return not active end
function GetModelDimensions()return {y=-2},{y=2,z=1}end
function GetEntityModel()return 123 end
function GetOffsetFromEntityInWorldCoords()return {x=0,y=0,z=0}end
function CreateCam()active=99;return 99 end
function SetCamCoord()end
function PointCamAtEntity()end
function SetCamFov()end
function HideHudAndRadarThisFrame()end
function IsNuiFocused()return false end
function IsPauseMenuActive()return false end
LocalPlayer={state={invOpen=false}}
exports={['screenshot-basic']={requestScreenshot=function(_,_,cb)shot=cb end}}
dofile('client/screenshots.lua')
local function start(token)
 event(token,'screenshot-basic',1024,20000,42,'A 123 BC')
 local work=threads[1];threads={};work();threads={}
end
source=65535;start('one');assert(active==99 and shot)
shot('data:image/jpeg;base64,/9j/');assert(not active and restored==1 and #sent==1)
shot('data:image/jpeg;base64,/9j/');assert(#sent==1)
speed=2;start('moving');assert(sent[2].reason=='vehicle_unavailable' and not active)
speed=0;start('timeout');local late=shot;timers[#timers]();assert(sent[3].reason=='timeout' and not active and restored==2)
late('data:image/jpeg;base64,/9j/');assert(#sent==3)
start('stop');assert(active);stops.onClientResourceStop('ts_bridge');assert(not active and restored==3)
print('PASS: vehicle photo camera, moving vehicle refused, one response, timeout/stop restore and late response ignored')
