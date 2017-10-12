-- switch
-- switch (i) {
-- 	[1] = function ( ... )
-- 		-- body
-- 	end,
-- 	[2] = function ( ... )
-- 		-- body
-- 	end,
-- 	default = function ( ... )
-- 		-- body
-- 	end,
-- }

function switch(case)
	return function (cases)
		local f = cases[case] or cases.default
		if f then
			return f(case)
		end
	end
end
