local system = class()
function system:ctor(concerns)
	self.concerns = {}
	for _, v in ipairs(concerns) do
		self.concerns[v] = true
	end
	self.entities = {}
	self.candidates = {}
end

function system:onAddComponent(c, entity)
	if not self.concerns[c] then return end
	if self.entities[entity.id] then return end

	local t = self.candidates[entity.id]
	if not t then
		t = {}
		for com, _ in pairs(self.concerns) do
			t[com] = true
		end
		self.candidates[entity.id] = t
	end
	t[c] = nil
	if table.count(t) == 0 then
		self.entities[entity.id] = entity
		self.candidates[entity.id] = nil
		if self.setup then
			self:setup(entity)
		end
	end
end

function system:onRemoveComponent(c, entity)
	if not self.concerns[c] then return end
	if self.entities[entity.id] then
		self.entities[entity.id] = nil
		self.candidates[entity.id] = {}
	end
	if self.candidates[entity.id] then
		self.candidates[entity.id][c] = true
	end
end

function system:onEntityDestroy(entity)
	if self.entities[entity.id] then
		self.entities[entity.id] = nil
	end
	if self.candidates[entity.id] then
		self.candidates[entity.id] = nil
	end
end


ecs.Sys = {}
function ecs.newsys(name, concerns)
	local sys = system.new(concerns)
	ecs.Sys[name] = sys
	return sys
end

events.ecs.addComponent.addListener(function (c, entity)
	for _, sys in pairs(ecs.Sys) do
		sys:onAddComponent(c, entity)
	end
end)
events.ecs.entityDestroy.addListener(function (entity)
	for _, sys in pairs(ecs.Sys) do
		sys:onEntityDestroy(entity)
	end
end)
