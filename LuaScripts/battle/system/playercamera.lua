local Com = ecs.Com
local concerns = {
	Com.playercamera,
	Com.view,
	Com.general,
	Com.transform,
}
local sys = ecs.newsys('playercamera', concerns)

local input = ecs.Single.input
local ratio = 3
local highThreshold = 10

function sys:setup(entity)
	local camera = entity:getComponent(Com.playercamera)
	local posCamera = camera.trans.localPosition
	camera.offset = UnityEngine.Vector3(posCamera.x, posCamera.y, posCamera.z)
end

function sys:update( ... )
	local entities = self:getEntities()
	for _, entity in pairs(entities) do
		local comCamera = entity:getComponent(Com.playercamera)
		local viewPosition = entity:getComponent(Com.transform).position
		local view = entity:getComponent(Com.view)
		comCamera.trans.localPosition = comCamera.offset + view.trans.localPosition
		
		local comGeneral = entity:getComponent(Com.general)
		comCamera.txtTroopCount.text = string.format('部队人数: %s', #comGeneral.retinues + 1)
	end
end

function sys:adjustCamera(id, direction)
	local comCamera = self:getEntity(id):getComponent(Com.playercamera)
	comCamera.offset = comCamera.offset + comCamera.offset.normalized * direction * ratio
end

function sys:_frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		if self:getEntity(v.id) then
			if v.highcamera then
				self:adjustCamera(self:getEntity(v.id), 1)
			end
			if v.lowcamera then
				self:adjustCamera(self:getEntity(v.id), -1)
			end
		end
	end
end