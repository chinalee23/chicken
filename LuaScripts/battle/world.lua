local game = require 'game'
local configWeapon = require 'config.weapon'

local Com = ecs.Com
local Sys = ecs.Sys

local _M = module()

local prefabConfig = {
	'Characters/16034011_Diffuse_Prefab',
	'Characters/16111001_Diffuse_Prefab',
	'Characters/16112001_Diffuse_Prefab',
	'Characters/16113001_Diffuse_Prefab',
	'Characters/16114001_Diffuse_Prefab',
	'Characters/16134011_Diffuse_Prefab',
	'Characters/16034011_Diffuse_Prefab',
	'Characters/16111001_Diffuse_Prefab',
	'Characters/16112001_Diffuse_Prefab',
	'Characters/16113001_Diffuse_Prefab',
	'Characters/16114001_Diffuse_Prefab',
	'Characters/16134011_Diffuse_Prefab',
}

local playerEntities = {}

local function loadComponents( ... )
	require 'battle.singleton.input'
	require 'battle.singleton.scene'
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
	require 'battle.component.logic.weapon'
	require 'battle.component.logic.rvo'
	
	require 'battle.component.behavior.transform'
	require 'battle.component.behavior.animation'
	require 'battle.component.behavior.playercamera'
	require 'battle.component.behavior.weapon'
end

local function loadSystems( ... )
	require 'battle.system.logic.move'
	require 'battle.system.logic.recruit'
	require 'battle.system.logic.attacker'
	require 'battle.system.logic.bullet'
	require 'battle.system.logic.die'
	require 'battle.system.logic.dismiss'
	require 'battle.system.logic.pickup'
	require 'battle.system.logic.rvo'

	require 'battle.system.behavior.transform'
	require 'battle.system.behavior.animation'
	require 'battle.system.behavior.playercamera'
	require 'battle.system.behavior.hpbar'
	require 'battle.system.behavior.weapon'
end

local function createEntities(data, root)
	local scene = ecs.Single.scene

	scene.rootPlayer = LuaInterface.Find(root, 'RootPlayer')
	for k, v in ipairs(data.characters) do
		local e = ecs.Entity.new()

		e:addComponent(Com.property, 2, 2, 50, 2, 1000, 2)
		e:addComponent(Com.logic.transform, v.pos)
		e:addComponent(Com.logic.animation, 'idle', 'idle', 'run', 'skill1')
		e:addComponent(Com.general)
		e:addComponent(Com.team, e.id)
		e:addComponent(Com.attacker)
		e:addComponent(Com.attackee)

		e:addComponent(Com.rvo)

		local go = LuaInterface.LoadPrefab(prefabConfig[e.id], scene.rootPlayer)
		go.name = e.id
		e:addComponent(Com.behavior.transform, go, 1.5)
		e:addComponent(Com.behavior.animation, go)
		if v.id == game.myid then
			local goCamera = LuaInterface.Find(root, 'Camera')
			e:addComponent(Com.playercamera, goCamera)
		end

		playerEntities[v.id] = e.id
		log.info('player', v.id, 'entity', e.id)
	end

	scene.rootNpc = LuaInterface.Find(root, 'RootNpc')
	for i = 1, #data.npcs do
		local e = ecs.Entity.new()
		
		e:addComponent(Com.property, 2, 2, 20, 2, 300)
		e:addComponent(Com.logic.transform, {data.npcs[i].pos[1], data.npcs[i].pos[2]})
		e:addComponent(Com.logic.animation, 'idle', 'idle_1', 'run_1', 'attack_1')
		e:addComponent(Com.npc)

		local go = LuaInterface.LoadPrefab('Characters/Fatguy', scene.rootNpc)
		go.name = e.id
		e:addComponent(Com.behavior.transform, go, 0.5)
		e:addComponent(Com.behavior.animation, go)
	end

	scene.rootWeapon = LuaInterface.Find(root, 'RootWeapon')
	for i = 1, #data.weapons do
		local e = ecs.Entity.new()

		local id = data.weapons[i].id
		e:addComponent(Com.logic.weapon, id, {data.weapons[i].pos[1], data.weapons[i].pos[2]})

		local go = LuaInterface.LoadPrefab(configWeapon[id].prefab, scene.rootWeapon)
		e:addComponent(Com.behavior.weapon, id, go)
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
	Sys.rvo:frameCalc()
	Sys.recruit:frameCalc()
	Sys.pickup:frameCalc()
	Sys.attacker:frameCalc()
	Sys.bullet:frameCalc()
	Sys.die:frameCalc()
	Sys.dismiss:frameCalc()

	Sys.behavior.transform:frameCalc()
	Sys.behavior.animation:frameCalc()

	ecs.Single.inputs = {}
end

function update( ... )
	Sys.behavior.transform:update()
	Sys.behavior.hpbar:update()
	Sys.behavior.weapon:update()
	Sys.playercamera:update()
end

function getPlayerEntityId(pid)
	return playerEntities[pid]
end

return _M