local Com = ecs.Com
local concern_1 = {
	Com.general,
}
local concern_2 = {
	Com.troop,
}
local sys = ecs.newsys('general', concern_1, concern_2)

function sys:addRetinue(entity)
	local id = entity:getComponent(Com.troop).id
	if id ~= entity.id then
		local comGeneral = self:getEntity(id, 1):getComponent(Com.general)
		table.insert(comGeneral.retinues, entity.id)
	end
end

function sys:removeRetinue(entity)
	local id = entity:getComponent(Com.troop).id
	if id ~= entity.id then
		local comGeneral = self:getEntity(id, 1):getComponent(Com.general)
		table.removeV(comGeneral.retinues, entity.id)
	end
end

function sys:setup(entity, concernIndex)
	if concernIndex == 2 then
		self:addRetinue(entity)
	end
end

function sys:_onRemoveComponent(entity, concernIndex)
	if concernIndex == 2 then
		self:removeRetinue(entity)
	end
end

function sys:_onEntityDestroy(entity, concernIndex)
	if concernIndex == 2 then
		self:removeRetinue(entity)
	end
end