math.NE = 0.000001

function math.equal(x, y)
	return math.abs(x-y) < math.NE
end