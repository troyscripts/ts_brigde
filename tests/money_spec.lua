local api, balance, online, reject, malformed, throws = {}, 100, true, false, false, false
TSBridgeServer = { SocietyResource = 'apex_banking', SocietyAccounts = { police = {'society_police'} } }
TSBridge = {
 Finite = function(n) return type(n)=='number' and n==n and math.abs(n)<math.huge end,
 PositiveInteger = function(n) return type(n)=='number' and n>0 and n%1==0 end,
 Callable = function(f) return type(f)=='function' end,
}
TSL = function(s) return s end
GetResourceState = function() return online and 'started' or 'stopped' end
GetInvokingResource = function() return 'test' end
local bank = {
 GetBusinessBalance = function(_,job) assert(job=='police'); return balance end,
 AddBusinessMoney = function(_,job,n)
  assert(job=='police'); if throws then error('provider unavailable') end
  if reject then return false,'rejected' end
  if malformed then return nil end
  balance=balance+n; return balance
 end,
 RemoveBusinessMoney = function(_,job,n)
  assert(job=='police'); if reject then return false,'rejected' end
  if balance<n then return false,'no_funds' end
  balance=balance-n; return balance
 end
}
exports=setmetatable({apex_banking=bank},{__call=function(_,name,fn) api[name]=fn end})
TriggerEvent=function(_,name,cb)
 assert(TSBridgeServer.SocietyResource=='esx_addonaccount')
 cb({money=balance, addMoney=function(n) balance=balance+n end, removeMoney=function(n) balance=balance-n end})
end
dofile('server/core/money.lua')
assert(api.GetSocietyBalance('police')==100)
assert(api.AddSocietyMoney('police',10).ok and balance==110)
assert(api.RemoveSocietyMoney('society_police',110).ok and balance==0)
assert(not api.RemoveSocietyMoney('police',1).ok and balance==0)
assert(not api.AddSocietyMoney('police',-1).ok)
reject=true; local r=api.AddSocietyMoney('police',10); assert(not r.ok and not r.uncertain and balance==0); reject=false
malformed=true; r=api.AddSocietyMoney('police',10); assert(not r.ok and r.uncertain); malformed=false
throws=true; r=api.AddSocietyMoney('police',10); assert(not r.ok and r.uncertain); throws=false
assert(api.AddSocietyMoney('police',10).ok) -- lock released after error
online=false; assert(api.GetSocietyBalance('police')==nil); assert(not api.AddSocietyMoney('police',10).ok); online=true
TSBridgeServer.SocietyResource='esx_addonaccount'
assert(api.AddSocietyMoney('police',10).ok and balance==20)
assert(api.RemoveSocietyMoney('police',20).ok and balance==0)
print('PASS: Apex/ESX credit, debit to zero, insufficient funds, invalid amount, rejection, malformed response, exception, outage, lock cleanup')
