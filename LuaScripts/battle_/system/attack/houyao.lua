local world = require 'battle.world'

local Com = ecs.Com
local concern_1 = {
	Com.property,
	Com.attack.houyao,
}
local sys = ecs.newsys('attack.houyao', concern_1)

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	local tmp = {}
	for _, v in pairs(entities) do
		local comHouyao = v:getComponent(Com.attack.houyao)
		local comProperty = v:getComponent(Com.property)
		if world.frameNo - comHouyao.startFrame >= comProperty.houyaoFrame then
			v:addComponent(Com.attack.lengque, comHouyao.target, world.frameNo)
			table.insert(tmp, v)
		end
	end

	for _, v in ipairs(tmp) do
		v:removeComponent(Com.attack.houyao)
	end
end