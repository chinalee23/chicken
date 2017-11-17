local entity = class()

local id = 0
function entity:ctor( ... )
	id = id + 1
	self.id = id
	self.components = {}
end

function entity:addComponent(c, ...)
	local com = c.new(...)
	self.components[c] = com

	events.ecs.addComponent(self, c)

	return com
end

function entity:getComponent(c)
	return self.components[c]
end

function entity:removeComponent(c)
	events.ecs.removeComponent(self, c)
	self.components[c] = nil
end

function entity:removeComponents(exclude)
	for k, _ in pairs(self.components) do
		if not exclude[k] then
			self:removeComponent(k)
		end
	end
end

function entity:destroy( ... )
	events.ecs.entityDestroy(self)
end

ecs.Entity = entity