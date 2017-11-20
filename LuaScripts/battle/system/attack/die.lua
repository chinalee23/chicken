local world = require 'battle.world'

local Com = ecs.Com
local concern = {
	Com.animation,
	Com.attack.die,
	Com.property,
}
local sys = ecs.newsys('attack.die', concern)

function sys:handleDying(entity, comDie)
	local comProperty = entity:getComponent(Com.property)
	if world.frameNo - comDie.startFrame > comProperty.dieFrame then
		entity:destroy()
	end
end

function sys:handleDie(entity, comDie)
	entity:removeComponents({
			[Com.view] = true,
			[Com.transform] = true,
			[Com.animation] = true,
			[Com.property] = true,
			[Com.attack.die] = true,
		})
	local comAnim = entity:getComponent(Com.animation)
	comAnim.tarAnim = 'die'
	
	comDie.dying = true
	comDie.startFrame = world.frameNo
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	local cnt = table.count(entities)
	local i = 0
	for _, v in pairs(entities) do
		i = i + 1
		local comDie = v:getComponent(Com.attack.die)
		if comDie.dying then
			self:handleDying(v, comDie)
		else
			self:handleDie(v, comDie)
		end
	end
	if i ~= cnt then
		log.error('!!!!!!!!!!  entity count ~= traverse count')
	end
end