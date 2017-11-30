local _M = module()

local json = require 'util.dkjson'

local regs = {}

function connect(ip, port, cb)
	LuaInterface.Connect(ip, port, cb)
end

function processMsg(msg)
	-- log.info('receive msg', msg)
	local jd = json.decode(msg)
	local msgType = jd.msgType
	if not regs[msgType] then return end
	for k, _ in pairs(regs[msgType]) do
		k(jd)
	end
end

function send(msg, msgType)
	msgType = msgType or 0
	LuaInterface.Send(msgType, msg)
end

function addListener(msgType, cb)
	local t = regs[msgType]
	if not t then
		t = {}
		regs[msgType] = t
	end
	if not t[cb] then
		t[cb] = true
	end
end

function removeListener(msgType, cb)
	if regs[msgType] and regs[msgType][cb] then
		regs[msgType][cb] = nil
	end
end

return _M