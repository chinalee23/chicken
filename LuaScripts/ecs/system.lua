local classConcern = class()
function classConcern:ctor(coms)
	self.coms = {}
	for _, v in ipairs(coms) do
		self.coms[v] = true
	end
	self.entities = {}
	self.candidates = {}
end

function classConcern:onAddComponent(entity, c)
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

function classConcern:onRemoveComponent(entity, c)
	local flag = false
	if not self.coms[c] then
		return flag
	end

	if self.entities[entity.id] then
		self.entities[entity.id] = nil
		self.candidates[entity.id] = {}
		flag = true
	end
	if self.candidates[entity.id] then
		self.candidates[entity.id][c] = true
	end
	return flag
end

function classConcern:onEntityDestroy(entity)
	local flag = false
	if self.entities[entity.id] then
		self.entities[entity.id] = nil
		flag = true
	end
	if self.candidates[entity.id] then
		self.candidates[entity.id] = nil
	end
	return flag
end




local system = class()
function system:ctor(tuple)
	self.concerns = {}
	for k, v in pairs(tuple) do
		local c = classConcern.new(v)
		self.concerns[k] = c
	end

	self.frameCalcTime = 0
end

function system:onAddComponent(entity, c)
	for k, v in pairs(self.concerns) do
		if v:onAddComponent(entity, c) and self.setup then
			self:setup(entity, k)
		end
	end
end

function system:onRemoveComponent(entity, c)
	for k, v in pairs(self.concerns) do
		if v:onRemoveComponent(entity, c) and self._onRemoveComponent then
			self:_onRemoveComponent(entity, k, c)
		end
	end
end

function system:onEntityDestroy(entity)
	for k, v in pairs(self.concerns) do
		if v:onEntityDestroy(entity) then
			if self._onEntityDestroy then
				self:_onEntityDestroy(entity, k)
			end
		end
	end
end

function system:getEntity(id, tupleKey)
	tupleKey = tupleKey or 1
	return self.concerns[tupleKey].entities[id]
end

function system:getEntities(tupleKey)
	tupleKey = tupleKey or 1
	return self.concerns[tupleKey].entities
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
function ecs.newsys(name, tuple)
	local sys = system.new(tuple)
	sys.__name = name
	if sys._ctor then sys:_ctor() end

	local seps = string.split(name, '.')
	local t = ecs.Sys
	for i = 1, #seps-1 do
		local sep = seps[i]
		if not t[sep] then
			t[sep] = {}
		end
		t = t[sep]
	end
	if t[seps[#seps]] then
		log.error('!!!!  duplicate sys', name)
	else
		t[seps[#seps]] = sys
		return sys
	end
end

local function traverse(t, func, ...)
	for _, v in pairs(t) do
		if v.__name then
			v[func](v, ...)
		else
			traverse(v, func, ...)
		end
	end
end

events.ecs.addComponent.addListener(function (entity, c)
	traverse(ecs.Sys, 'onAddComponent', entity, c)
end)
events.ecs.removeComponent.addListener(function (entity, c)
	traverse(ecs.Sys, 'onRemoveComponent', entity, c)
end)
events.ecs.entityDestroy.addListener(function (entity)
	traverse(ecs.Sys, 'onEntityDestroy', entity)
end)
