local classMap = require 'math.map'

local map = ecs.newsingle('map')
map.teamMap = classMap.new(100, 100, 1, -43, -66)
map.attackeeMap = classMap.new(100, 100, 1, -43, -66)