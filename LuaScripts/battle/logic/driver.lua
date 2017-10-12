local CHARACTER = require 'battle.logic.character'
local game = require 'game'

local _M = {}

local characters
local commands = {}
local results

-- 准备战斗
-- 入参：战斗数据
function _M.prepare(data)
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

return _M