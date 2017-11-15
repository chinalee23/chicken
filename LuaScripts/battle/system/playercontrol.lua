local Com = ecs.Com
local concerns = {
	Com.playercontrolled,
}
local sys = ecs.newsys('playercontrol', concerns)

local input = ecs.Single.input

function sys:onControlMsg(msg)
	for _, v in ipairs(msg) do
		local entity = self:getEntity(v.id)
		if entity then
			local com = entity:getComponent(Com.transform)
			com.direction = v.direction
		end
	end
end

function sys:frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		local entity = self:getEntity(v.id)
		
	end
end