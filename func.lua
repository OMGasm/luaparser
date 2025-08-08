local mod = {}

function mod.map(t, f)
	local c = {}
	for k, v in type(t) == "table" and pairs(t) or t do
		c[k] = f(v, k, t)
	end
	return c
end

function mod.forEach(t, f)
	for k, v in pairs(t) do
		f(v, k, t)
	end
	return t
end

return mod
