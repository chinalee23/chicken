math.NE = 0.000001

function math.approximate(x, y)
	return math.abs(x-y) < math.NE
end