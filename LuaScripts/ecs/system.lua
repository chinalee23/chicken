local classConcern = class()
function classConcern:ctor(coms)
	self.coms = {}
	for _, v in ipairs(coms) do
		self.coms[v] = true
	end
	self.entities = {}
	self.candidates = {}
end

function classConcern:onAddComponent(c, entity)
	if not self.coms[c] then return end
	if self.entities[entity.id] then return end

	local t = self.candidates[entity.id]
	if not t then
		t = {}
		for com, _ in pairs(self.coms) do
			t[com] = true
		end
		self.candidates[entity.id] = t
	end
	t[c] = nil
	if table.count(t) == 0 then
		self.entities[entity.id] = entity
		self.candidates[entity.id] = nil
		return true
	end
end

function classConcern:onRemoveComponent(c, entity)
	if not self.coms[c] then return end
	if self.entities[entity.id] then
		self.entities[entity.id] = nil
		self.candidates[entity.id] = {}
	end
	if self.candidates[entity.id] then
		self.candidates[entity.id][c] = true
	end
end

function classConcern:onEntityDestroy(entity)
	if self.entities[entity.id] then
		self.entities[entity.id] = nil
	end
	if self.candidates[entity.id] then
		self.candidates[entity.id] = nil
	end
end




local system = class()
function system:ctor(...)
	local args = {...}
	self.concerns = {}
	for _, v in ipairs(args) do
		local c = classConcern.new(v)
		table.insert(self.concerns, c)
	end

	self.frameCalcTime = 0
end

function system:onAddComponent(c, entity)
	for k, v in ipairs(self.concerns) do
		if v:onAddComponent(c, entity) and self.setup then
			self:setup(entity, k)
		end
	end
end

function system:onRemoveComponent(c, entity)
	for _, v in ipairs(self.concerns) do
		v:onRemoveComponent(c, entity)
	end
end

function system:onEntityDestroy(entity)
	for _, v in ipairs(self.concerns) do
		v:onEntityDestroy(entity)
	end
end

function system:getEntity(id, concernIndex)
	concernIndex = concernIndex or 1
	return self.concerns[concernIndex].entities[id]
end

function system:getEntities(concernIndex)
	concernIndex = concernIndex or 1
	return self.concerns[concernIndex].entities
end

function system:frameCalc()
	if self._frameCalc then
		local start = Time.realtimeSinceStartup
		self:_frameCalc()
		local offset = Time.realtimeSinceStartup - start
		if offset > self.frameCalcTime then
			self.frameCalcTime = offset
		end
	end
end


ecs.Sys = {}
function ecs.newsys(name, ...)
	local sys = system.new(...)
	sys.__name = name
	ecs.Sys[name] = sys
	return sys
end

events.ecs.addComponent.addListener(function (c, entity)
	for _, sys in pairs(ecs.Sys) do
		sys:onAddComponent(c, entity)
	end
end)
events.ecs.removeComponent.addListener(function (c, entity)
	for _, sys in pairs(ecs.Sys) do
		sys:onRemoveComponent(c, entity)
	end
end)
events.ecs.entityDestroy.addListener(function (entity)
	for _, sys in pairs(ecs.Sys) do
		sys:onEntityDestroy(entity)
	end
end)
