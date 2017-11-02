local Com = ecs.Com
local concerns = {
	Com.playercamera,
	Com.view,
	Com.troop,
}
local sys = ecs.newsys('playercamera', concerns)

local ratio = 3
local highThreshold = 10

function sys:setup(entity)
	local camera = entity:getComponent(Com.playercamera)
	local view = entity:getComponent(Com.view)
	camera.offset = camera.trans.localPosition - view.trans.localPosition
end

function sys:update( ... )
	for _, entity in pairs(self.entities) do
		local troop = entity:getComponent(Com.troop)
		local camera = entity:getComponent(Com.playercamera)
		local view = entity:getComponent(Com.view)
		local offset = camera.offset
		if #troop.retinues > highThreshold then
			offset = camera.offset + camera.offset.normalized * ratio
		end
		camera.trans.localPosition = offset + view.trans.localPosition
	end
end