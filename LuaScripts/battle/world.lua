local _M = module()

local game = require 'game'

local prefabConfig = {
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
		e:addComponent(ecs.Com.view, root, prefabConfig[e.id])
		e:addComponent(ecs.Com.rvo)

		if v.id == game.myid then
			local goCamera = LuaInterface.Find(root, 'Camera')
			local txt = LuaInterface.Find(root, 'UIRoot/Canvas/TextTroopCount', 'Text')
			e:addComponent(ecs.Com.playercamera, goCamera, txt)
		end

		playerEntities[v.id] = e.id
		entities[e.id] = e
	end

	local rootNpc = LuaInterface.Find(root, 'npcs')
	for i = 1, #data.npcs do
		local x = data.npcs[i].pos[1]
		local y = data.npcs[i].pos[2]
		local e = ecs.Entity.new()
		
		e:addComponent(ecs.Com.transform, {x, y})
		e:addComponent(ecs.Com.troop, 'villager')
		e:addComponent(ecs.Com.view, rootNpc, 'Prefab/npc/N_pikeman_01/N_pikeman_01_low')

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
function frameCalc( ... )
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