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
	-- body
end

return _M