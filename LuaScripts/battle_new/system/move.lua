local Com = ecs.Com

local tuple = {
	general = {
		Com.general,
		Com.transform,
		Com.property,
	},
	retinue = {
		Com.retinue,
		Com.transform,
		Com.property,
	},
}
local sys = ecs.newsys('move', tuple)

function sys:setPostion(entity, direction)
	local comTrans = entity:getComponent(Com.transform)
	local comProperty = entity:getComponent(Com.property)
	comTrans.position = comTrans.position + direction * comProperty.speed
end

function sys:move(eGeneral, direction)
	self:setPostion(eGeneral, direction)
	local comGeneral = eGeneral:getComponent(Com.general)
	for _, v in ipairs(comGeneral.retinues) do
		local eRetinue = self:getEntity('retinue', v)
		self:setPostion(eRetinue, direction)
	end
end

function sys:_frameCalc( ... )
	local generals = self:getEntities('general')
	for k, v in pairs(generals) do
		-- get input
		local input = getInput(k)
		if input.direction then
			self:move(v, input.direction)
		end
	end
end