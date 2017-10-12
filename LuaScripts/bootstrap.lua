local _M = module()

function start( ... )
	local game = require 'game'
	game.start()
end

function update( ... )
	events.update()
end

function fixedUpdate( ... )
	events.fixedUpdate()
end

return _M