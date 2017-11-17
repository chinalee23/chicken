ecs.Com = {}
function ecs.newcom(name)
	local com = class()
	com._name = name

	local seps = string.split(name, '.')
	local t = ecs.Com
	for i = 1, #seps-1 do
		local sep = seps[i]
		if not t[sep] then
			t[sep] = {}
		end
		t = t[sep]
	end

	if t[seps[#seps]] then
		log.error('!!!!  duplicate com', name)
	else
		t[seps[#seps]] = com
		return com
	end
end

ecs.Single = {}
function ecs.newsingle(name)
	local com = {}
	ecs.Single[name] = com
	return com
end