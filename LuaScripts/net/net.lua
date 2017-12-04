local _M = module()

local pb = require 'protobuf.protobuf'

local regs = {}

function connect(ip, port, cb)
	LuaInterface.Connect(ip, port, cb)
end

function processMsg(pbType, data)
	local t = regs[pbType]
	if not t then return end
	
	local msg
	if t.proto and data then
		msg, err = pb.decode(t.proto, data)
		if not msg then
			log.info('decode err', pbType, err)
		end
	end
	for k, _ in pairs(t.funcs) do
		k(msg)
	end
end

function send(msgType, msg)
	local pbType = pb.enum_id('sgio.battle.MsgType', msgType)
	LuaInterface.Send(pbType, msg)
end

function addListener(msgType, cb, proto)
	local pbType = pb.enum_id('sgio.battle.MsgType', msgType)
	local t = regs[pbType]
	if not t then
		t = {
			proto = proto,
			funcs = {},
		}
		regs[pbType] = t
	end
	if not t.funcs[cb] then
		t.funcs[cb] = true
	end
end

function removeListener(pbType, cb)
	if regs[pbType] and regs[pbType].funcs[cb] then
		regs[pbType].funcs[cb] = nil
	end
end

return _M