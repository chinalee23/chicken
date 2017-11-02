local Com = ecs.Com
local concerns = {
	Com.playercontrolled,
}
local sys = ecs.newsys('playercontrol', concerns)

local input = ecs.Single.input

function sys:onControlMsg(msg)
	for _, v in ipairs(msg) do
		if self.entities[v.id] then
			local com = self.entities[v.id]:getComponent(Com.transform)
			com.direction = v.direction
		end
	end
end

function sys:frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		local entity = self.entities[v.id]
		
	end
end