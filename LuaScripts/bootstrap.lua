local _M = module()

local net = require 'net.net'

function update( ... )
	events.update()
end

function fixedUpdate( ... )
	events.fixedUpdate()
end

function processMsg(msgType, data)
	net.processMsg(msgType, data)
end

return _M