local _M = module()

local gameObject

function awake(go)
	gameObject = go

	local btn = LuaInterface.Find(go, 'BtnStart')
	LuaInterface.AddClick(btn, function ( ... )
		LuaInterface.DestroyGameObject(go)
		local game = require 'game'
		game.start()
	end)
end

function start( ... )
	-- body
end

function update( ... )
	-- body
end

function ondestroy( ... )
	-- body
end

return _M