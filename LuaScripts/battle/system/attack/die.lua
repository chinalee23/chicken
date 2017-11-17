local world = require 'battle.world'

local Com = ecs.Com
local concern = {
	Com.attack.die,
	Com.property,
}
local sys = ecs.newsys('attack.die', concern)

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	local cnt = table.count(entities)
	local i = 0
	for _, v in pairs(entities) do
		i = i + 1
		local comDie = v:getComponent(Com.attack.die)
		local comProperty = v:getComponent(Com.property)
		if world.frameNo - comDie.startFrame > comProperty.dieFrame then
			v:destroy()
		end
	end
	if i ~= cnt then
		log.error('!!!!!!!!!!  entity count ~= traverse count')
	end
end