local behavior = require 'battle.behavior.battle_behavior'

local gameObject

local function awake(go)
	gameObject = go
	
	behavior.start(go)
end

local function start( ... )
	-- body
end

local function update( ... )
	-- body
end

return {
	awake = awake,
	start = start,
	update = update,
}