local _M = module()

local logic = require 'battle.logic.driver'
local CHARACTER = require 'battle.behavior.character'
local NPC = require 'battle.behavior.npc'

characters = {}
npcs = {}

function prepare(root)
	for _, v in pairs(logic.characters) do
		local c = instance(CHARACTER, v, root)
		characters[v.id] = c
	end

	local rootNpc = LuaInterface.Find(root, 'npcs')
	for _, v in ipairs(logic.npcs) do
		local n = instance(NPC, v, rootNpc)
		table.insert(npcs, n)
	end
end

local lastTime
function go( ... )
	if not lastTime then
		lastTime = UnityEngine.Time.time
	else
		local newTime = UnityEngine.Time.time
		-- log.info(newTime - lastTime)
		lastTime = newTime
	end
	for _, v in pairs(characters) do
		v:go()
	end
	for _, v in ipairs(npcs) do
		v:go()
	end
end

return _M