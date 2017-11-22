local game = require 'game'
local Com = ecs.Com
local Sys = ecs.Sys

local _M = module()

local prefabConfig = {
	'Prefab/character/16021002_Diffuse_Prefab',
	'Prefab/character/16021007_Diffuse_Prefab',
	'Prefab/Player/Female01Base3D/female01_base_prefab',
	'Prefab/Player/Male01/male01_base_prefab',
	'Prefab/Player/Male02Base3D/male02_base_prefab',
	'Prefab/Player/Female03Base3D/female03_base_prefab',
}

local playerEntities = {}

local function loadComponents( ... )
	require 'battle.singleton.input'
	require 'battle.singleton.ui'
	require 'battle.singleton.map'
	
	require 'battle.component.logic.property'
	require 'battle.component.logic.transform'
	require 'battle.component.logic.general'
	require 'battle.component.logic.npc'
	require 'battle.component.logic.retinue'

	require 'battle.component.behavior.unit'
	require 'battle.component.behavior.playercamera'
end

local function loadSystems( ... )
	require 'battle.system.logic.move'
	require 'battle.system.logic.recruit'	

	require 'battle.system.behavior.unit'
	require 'battle.system.behavior.playercamera'
end

local function createEntities(data, root)
	for k, v in ipairs(data.characters) do
		local e = ecs.Entity.new()

		e:addComponent(Com.property, 2)
		e:addComponent(Com.transform, v.pos)
		e:addComponent(Com.general)
		e:addComponent(Com.unit, root, prefabConfig[e.id], 1.5)
		if v.id == game.myid then
			local goCamera = LuaInterface.Find(root, 'Camera')
			e:addComponent(Com.playercamera, goCamera)
		end

		playerEntities[v.id] = e.id
	end

	local rootNpc = LuaInterface.Find(root, 'npcs')
	for i = 1, #data.npcs do
		local x = data.npcs[i].pos[1]
		local y = data.npcs[i].pos[2]
		local e = ecs.Entity.new()
		
		e:addComponent(Com.property, 2)
		e:addComponent(Com.transform, {x, y})
		e:addComponent(Com.npc)
		e:addComponent(Com.unit, rootNpc, 'Prefab/character/16011001_Diffuse_Prefab')
	end
end

function init( ... )
	loadComponents()
	loadSystems()
end

function build(data, root)
	math.randomseed(data.seed)
	log.info('seed', data.seed)
	
	createEntities(data, root)
end

frameInterval = 0.1
frameNo = 0
function frameCalc( ... )
	frameNo = frameNo + 1

	Sys.move:frameCalc()
	Sys.recruit:frameCalc()

	Sys.unit:frameCalc()

	ecs.Single.inputs.direction = nil
end

function update( ... )
	Sys.unit:update()
	Sys.playercamera:update()
end

function getPlayerEntityId(pid)
	return playerEntities[pid]
end

return _M