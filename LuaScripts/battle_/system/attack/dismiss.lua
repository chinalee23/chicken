local world = require 'battle.world'

local Com = ecs.Com
local concern = {
	Com.attack.dismiss,
}
local sys = ecs.newsys('attack.dismiss', concern)

local interval = 10

function sys:handleDismissing(entity, comDismiss, tmp)
	if world.frameNo - comDismiss.startFrame > interval then
		entity:addComponent(Com.npc)
		table.insert(tmp, entity)
	end
end

function sys:handleDismiss(entity, comDismiss)
	entity:removeComponents({
			[ecs.Com.transform] = true,
			[ecs.Com.property] = true,
			[ecs.Com.view] = true,
			[ecs.Com.attack.dismiss] = true,
		})
	comDismiss.dismissing = true
	comDismiss.startFrame = world.frameNo
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	local tmp = {}
	for _, v in pairs(entities) do
		local comDismiss = v:getComponent(Com.attack.dismiss)
		if comDismiss.dismissing then
			self:handleDismissing(v, comDismiss, tmp)
		else
			self:handleDismiss(v, comDismiss)
		end
	end

	for _, v in ipairs(tmp) do
		v:removeComponent(Com.attack.dismiss)
	end
end