local _M = module()

local game = require 'game'

local entities = {}
local playerEntities = {}

local function loadComponents( ... )
	require 'battle.component.Singleton.input'

	require 'battle.component.playercontrolled'
	require 'battle.component.transform'
	require 'battle.component.rvo'
	require 'battle.component.troop'
	require 'battle.component.view'
	require 'battle.component.playercamera'
end

local function loadSystems( ... )
	require 'battle.system.move'
	require 'battle.system.recruit'
	require 'battle.system.rvo'
	require 'battle.system.view'
	require 'battle.system.playercamera'
	require 'battle.system.blink'
end

local function createEntities(data, root)
	for k, v in ipairs(data.characters) do
		local e = ecs.Entity.new()

		e:addComponent(ecs.Com.transform, v.pos)
		e:addComponent(ecs.Com.playercontrolled)
		e:addComponent(ecs.Com.troop, 'general', e.id)
		e:addComponent(ecs.Com.view, root, 'Prefab/Player/Male01/male01_base_prefab')

		if v.id == game.myid then
			e:addComponent(ecs.Com.rvo)
			local goCamera = LuaInterface.Find(root, 'Camera')
			local txt = LuaInterface.Find(root, 'UIRoot/Canvas/TextTroopCount', 'Text')
			e:addComponent(ecs.Com.playercamera, goCamera, txt)
		end

		playerEntities[v.id] = e.id
		entities[e.id] = e
	end

	local rootNpc = LuaInterface.Find(root, 'npcs')
	for i = 1, 100 do
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		local e = ecs.Entity.new()
		
		e:addComponent(ecs.Com.transform, {x, y})
		e:addComponent(ecs.Com.troop, 'villager')
		e:addComponent(ecs.Com.view, rootNpc, 'Prefab/npc/N_pikeman_01/N_pikeman_01_low')

		entities[e.id] = e
	end
end

function build(data, root)
	math.randomseed(data.seed)

	loadComponents()
	loadSystems()
	
	createEntities(data, root)
end

frameStartTime = 0
frameInterval = 0.066
function frameCalc( ... )
	frameStartTime = UnityEngine.Time.realtimeSinceStartup

	ecs.Sys.move:frameCalc()
	ecs.Sys.rvo:frameCalc()
	ecs.Sys.blink:frameCalc()
	ecs.Sys.recruit:frameCalc()
	ecs.Sys.view:frameCalc()
	ecs.Sys.playercamera:frameCalc()

	ecs.Single.input.inputs = {}
end

function update( ... )
	ecs.Sys.view:update()
	ecs.Sys.playercamera:update()
end

function getPlayerEntityId(pid)
	return playerEntities[pid]
end

return _M