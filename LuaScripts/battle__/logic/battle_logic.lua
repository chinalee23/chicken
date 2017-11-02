local CHARACTER = require 'battle.logic.character'
local game = require 'game'

local _M = {}

local characters
local commands = {}
local results

-- 准备战斗
-- 入参：战斗数据
function _M.prepare(data)
	-- local data = game.battle.battleData
	characters = {}
	for _, v in ipairs(data) do
		local c = instance(CHARACTER, v)
		characters[v.id] = c
	end
end

-- 执行一回合逻辑计算
-- 入参：逻辑输入
function _M.go(data)
	results = {}

	for _, v in ipairs(commands) do
		local c = characters[v.id]
		executeCommand(c, v.data)
	end

	return results
end

-- function _M.executeCommand(c, command)
-- 	if command == 'left' then
-- 		c.position = c.position + Vector2.left
-- 	elseif command == 'right' then
-- 		c.position = c.position + Vector2.right
-- 	elseif command == 'up' then
-- 		c.position = c.position + Vector2.up
-- 	else
-- 		c.position = c.position + Vector2.down
-- 	end
-- 	table.insert(results, {
-- 			id = c.id,
-- 			data = {
-- 				position = {c.position.x, c.position.y},
-- 			},
-- 		})
-- end



-- function _M.setCommand(command)
-- 	table.insert(commands, command)
-- end

return _M