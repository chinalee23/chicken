local Com = ecs.Com
local concerns = {
	Com.playercamera,
	Com.view,
	Com.troop,
}
local sys = ecs.newsys('playercamera', concerns)

local input = ecs.Single.input
local ratio = 3
local highThreshold = 10

function sys:setup(entity)
	local camera = entity:getComponent(Com.playercamera)
	local view = entity:getComponent(Com.view)
	camera.offset = camera.trans.localPosition - view.trans.localPosition
end

function sys:update( ... )
	for _, entity in pairs(self.entities) do
		local camera = entity:getComponent(Com.playercamera)
		local view = entity:getComponent(Com.view)
		camera.trans.localPosition = camera.offset + view.trans.localPosition

		local troop = entity:getComponent(Com.troop)
		camera.txtTroopCount.text = string.format('部队人数: %s', #troop.retinues + 1)
	end
end

function sys:adjustCamera(entity, direction)
	local camera = entity:getComponent(Com.playercamera)
	camera.offset = camera.offset + camera.offset.normalized * direction * ratio
end

function sys:frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		if v.highcamera then
			self:adjustCamera(self.entities[v.id], 1)
		end
		if v.lowcamera then
			self:adjustCamera(self.entities[v.id], -1)
		end
	end
end