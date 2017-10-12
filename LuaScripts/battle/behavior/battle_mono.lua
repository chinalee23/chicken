local _M = module()

local driver = require 'battle.logic.driver'
local CHARACTER = require 'battle.behavior.character'

local gameObject
local characters = {}

local function prepare( ... )
	for k, _ in pairs(driver.characters) do
		local c = instance(CHARACTER, k, gameObject)
		characters[k] = c
	end
end

function awake(go)
	gameObject = go
end

function start( ... )
	prepare()
end

function update( ... )
	for _, v in pairs(characters) do
		v:update()
	end
end

function ondestroy( ... )
	-- body
end

return _M