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

	events.ecs.addComponent(c, self)

	return com
end

function entity:getComponent(c)
	return self.components[c]
end

function entity:removeComponent(c)
	self.components[c] = nil
	events.ecs.removeComponent(c, self)
end

function entity:destroy( ... )
	events.ecs.entityDestroy(self)
end

ecs.Entity = entity