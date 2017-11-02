local _M = module()

local gameObject

function awake(go)
	gameObject = go

	local btnOnline = LuaInterface.Find(go, 'BtnOnline')
	local btnOffline = LuaInterface.Find(go, 'BtnOffline')
	local cb = function (btn)
		LuaInterface.DestroyGameObject(go)
		local game = require 'game'
		if btn == btnOnline then
			game.start(true)
		else
			game.start(false)
		end
	end
	LuaInterface.AddClick(btnOnline, cb)
	LuaInterface.AddClick(btnOffline, cb)

	local btnTest = LuaInterface.Find(go, 'BtnTest')
	LuaInterface.AddClick(btnTest, function ( ... )
		LuaInterface.LoadScene('rvo')
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

function fixedupdate( ... )
	-- body
end

return _M