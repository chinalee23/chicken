local classTree = require 'battle.kdtree'

local dots = {
	Vector2(2, 3),
	Vector2(5, 4),
	Vector2(9, 6),
	Vector2(4, 7),
	Vector2(8, 1),
	Vector2(7, 2),
}

local tree = classTree.new()
tree:create(dots)
log.info('create a tree')