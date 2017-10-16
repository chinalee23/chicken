local _M = module()

local driver = require 'battle.logic.driver'
local CHARACTER = require 'battle.behavior.character'
local sysFood = require 'battle.logic.sys_food'

local gameObject
local characters = {}
local foods = {}

local function prepare( ... )
	for k, _ in pairs(driver.characters) do
		local c = instance(CHARACTER, k, gameObject)
		characters[k] = c
	end
end

local function updateFoods( ... )
	for i, v in ipairs(sysFood.foods) do
		if i > #foods then
			local go = LuaInterface.LoadPrefab('Prefab/Food', gameObject)
			table.insert(foods, go)
		end
		LuaInterface.SetLocalPosition(foods[i], v[1]-569, v[2]-321, 0)
		LuaInterface.SetLocalScale(foods[i], 6, 6, 1)
	end
end

function awake(go)
	gameObject = go
end

function start( ... )
	prepare()

	events.battleMonoPrepared()
end

function update( ... )
	for _, v in pairs(characters) do
		v:update()
	end
	updateFoods()
end

function ondestroy( ... )
	-- body
end

return _M