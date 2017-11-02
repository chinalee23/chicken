local _M = module()

local CHARACTER = require 'battle.logic.character'
local NPC = require 'battle.logic.npc'

local sysCharacter = require 'battle.logic.system.system_character'
local sysRVO = require 'battle.logic.system.system_rvo'
local sysNpc = require 'battle.logic.system.system_npc'

characters = {}
npcs = {}

function prepare(data)
	for _, v in ipairs(data.characters) do
		local c = instance(CHARACTER, v)
		characters[v.id] = c
		sysRVO.setup(c)
	end

	math.randomseed(data.seed)

	for i = 1, 100 do
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		local n = instance(NPC, x, y)
		table.insert(npcs, n)
	end
end

function go(input)
	for id, v in pairs(characters) do
		sysCharacter.calc(v, input[id])
		sysRVO.calc(v)
	end
	sysNpc.calc(characters, npcs)
end

return _M