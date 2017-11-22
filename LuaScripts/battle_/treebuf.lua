local kdtree = require 'math.kdtree'

local buff = {}

local function getTree(id)
	return buff[id]
end

local function createTree(id, nodes)
	buff[id] = kdtree.new(nodes)
	return buff[id]
end

local function clear( ... )
	buff = {}
end

return {
	getTree = getTree,
	createTree = createTree,

	clear = clear,
}