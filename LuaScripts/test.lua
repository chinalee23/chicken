require 'util/class'
local quadrangle = require 'math/quadrangle'
local circle = require 'math/circle'
local Vector2 = require 'math/Vector2'
local umath = require 'math/util'
local kdtree = require 'math/kdtree'

local dots = {
	Vector2(2, 3),
	Vector2(5, 4),
	Vector2(9, 6),
	Vector2(4, 7),
	Vector2(8, 1),
	Vector2(7, 2),
}
local tree = kdtree.new()
tree:createTree(dots)

local dot = Vector2(7.5, 1.5)
local node, dist = tree:queryClosest(dot)
print(math.sqrt(dist), node.dot)

local q = quadrangle.new(Vector2(0, 0), Vector2(0, 0))
local qe = q:expend(2)
print(qe.min, qe.max)