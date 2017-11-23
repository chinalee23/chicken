local classMap = require 'math.map'

local map = ecs.newsingle('map')
map.teamMap = classMap.new(100, 100, 1)
map.attackeeMap = classMap.new(100, 100, 1)