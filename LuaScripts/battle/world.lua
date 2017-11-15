local _M = module()

local game = require 'game'

local prefabConfig = {
	'Prefab/character/16021002_Diffuse_Prefab',
	'Prefab/character/16021007_Diffuse_Prefab',
	'Prefab/Player/Female01Base3D/female01_base_prefab',
	'Prefab/Player/Male01/male01_base_prefab',
	'Prefab/Player/Male02Base3D/male02_base_prefab',
	'Prefab/Player/Female03Base3D/female03_base_prefab',
}

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
	require 'battle.component.npc'
	require 'battle.component.attack'
	require 'battle.component.animation'
end

local function loadSystems( ... )
	require 'battle.system.move'
	require 'battle.system.recruit'
	require 'battle.system.rvo'
	require 'battle.system.view'
	require 'battle.system.playercamera'
	require 'battle.system.blink'
	require 'battle.system.attack'
	require 'battle.system.animation'
end

local function createEntities(data, root)
	for k, v in ipairs(data.characters) do
		local e = ecs.Entity.new()

		e:addComponent(ecs.Com.transform, v.pos)
		e:addComponent(ecs.Com.playercontrolled)
		e:addComponent(ecs.Com.troop, 'general', e.id)
		e:addComponent(ecs.Com.view, root, prefabConfig[e.id], 1.5, 'idle')
		e:addComponent(ecs.Com.rvo)
		e:addComponent(ecs.Com.animation)

		if v.id == game.myid then
			local goCamera = LuaInterface.Find(root, 'Camera')
			local txt = LuaInterface.Find(root, 'UIRoot/Canvas/TextTroopCount', 'Text')
			e:addComponent(ecs.Com.playercamera, goCamera, txt)
			e:addComponent(ecs.Com.attack, 4, 2, 10)
		else
			e:addComponent(ecs.Com.attack, 0)
		end

		playerEntities[v.id] = e.id
		entities[e.id] = e
	end

	local rootNpc = LuaInterface.Find(root, 'npcs')
	for i = 1, #data.npcs do
		local x = data.npcs[i].pos[1]
		local y = data.npcs[i].pos[2]
		local e = ecs.Entity.new()
		
		e:addComponent(ecs.Com.npc)
		e:addComponent(ecs.Com.transform, {x, y})
		e:addComponent(ecs.Com.view, rootNpc, 'Prefab/character/16011001_Diffuse_Prefab', 1.2, 'idle')

		entities[e.id] = e
	end
end

function build(data, root)
	math.randomseed(data.seed)
	log.info('seed', data.seed)

	loadComponents()
	loadSystems()
	
	createEntities(data, root)
end

frameInterval = 0.1
frameNo = 0
function frameCalc( ... )
	frameNo = frameNo + 1

	ecs.Sys.attack:frameCalc()
	ecs.Sys.move:frameCalc()
	ecs.Sys.rvo:frameCalc()
	ecs.Sys.blink:frameCalc()
	ecs.Sys.recruit:frameCalc()
	ecs.Sys.view:frameCalc()
	ecs.Sys.playercamera:frameCalc()
	ecs.Sys.animation:frameCalc()

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