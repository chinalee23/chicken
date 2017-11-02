ecs.Com = {}
function ecs.newcom(name)
	local com = class()
	com._name = name
	ecs.Com[name] = com
	return com
end

ecs.Single = {}
function ecs.newsingle(name)
	local com = {}
	ecs.Single[name] = com
	return com
end