local _M = module()

local CHARACTER = require 'battle.logic.character'

characters = {}

function prepare(data)
	for _, v in ipairs(data) do
		local c = instance(CHARACTER, v)
		characters[v.id] = c
	end
end

function go( ... )
	for _, c in pairs(characters) do
		c:calc()
	end
end

return _M