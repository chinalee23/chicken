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
	require 'battle.component.logic.animation'
	require 'battle.component.logic.general'
	require 'battle.component.logic.npc'
	require 'battle.component.logic.retinue'
	require 'battle.component.logic.team'
	require 'battle.component.logic.attacker'
	require 'battle.component.logic.attackee'
	require 'battle.component.logic.bullet'
	require 'battle.component.logic.die'
	require 'battle.component.logic.dismiss'

	require 'battle.component.behavior.transform'
	require 'battle.component.behavior.animation'
	require 'battle.component.behavior.playercamera'
end

local function loadSystems( ... )
	require 'battle.system.logic.move'
	require 'battle.system.logic.recruit'
	require 'battle.system.logic.attacker'
	require 'battle.system.logic.bullet'
	require 'battle.system.logic.die'
	require 'battle.system.logic.dismiss'
	
	require 'battle.system.behavior.transform'
	require 'battle.system.behavior.animation'
	require 'battle.system.behavior.playercamera'
	require 'battle.system.behavior.hpbar'
end

local function createEntities(data, root)
	for k, v in ipairs(data.characters) do
		local e = ecs.Entity.new()

		e:addComponent(Com.property, 2, 10, 100, 5, 1000)
		e:addComponent(Com.logic.transform, v.pos)
		e:addComponent(Com.logic.animation, 'idle')
		e:addComponent(Com.general)
		e:addComponent(Com.team, e.id)
		e:addComponent(Com.attacker)
		e:addComponent(Com.attackee)

		local go = LuaInterface.LoadPrefab(prefabConfig[e.id], root)
		go.name = e.id
		e:addComponent(Com.behavior.transform, go, 1.5)
		e:addComponent(Com.behavior.animation, go)
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
		
		e:addComponent(Com.property, 2, 3, 100, 5, 100)
		e:addComponent(Com.logic.transform, {x, y})
		e:addComponent(Com.logic.animation, 'idle')
		e:addComponent(Com.npc)

		local go = LuaInterface.LoadPrefab('Prefab/character/16011001_Diffuse_Prefab', rootNpc)
		go.name = e.id
		e:addComponent(Com.behavior.transform, go)
		e:addComponent(Com.behavior.animation, go)
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

frameInterval = Time.fixedDeltaTime
log.info('frameInterval', frameInterval)
frameNo = 0
frameStartTime = 0
function frameCalc( ... )
	frameNo = frameNo + 1
	frameStartTime = Time.time

	Sys.move:frameCalc()
	Sys.recruit:frameCalc()
	Sys.attacker:frameCalc()
	Sys.bullet:frameCalc()
	Sys.die:frameCalc()
	Sys.dismiss:frameCalc()

	Sys.behavior.transform:frameCalc()
	Sys.behavior.animation:frameCalc()

	ecs.Single.inputs.direction = nil
end

function update( ... )
	Sys.behavior.transform:update()
	Sys.behavior.hpbar:update()
	Sys.playercamera:update()
end

function getPlayerEntityId(pid)
	return playerEntities[pid]
end

return _M