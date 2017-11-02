local _M = module()

local net = require 'net.net'

function update( ... )
	events.update()
end

function fixedUpdate( ... )
	events.fixedUpdate()
end

function processMsg(msg)
	net.processMsg(msg)
end

return _M