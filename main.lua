#!/usr/bin/env luajit

function Main()
	assert(arg[1])
	local f = assert(io.open(arg[1]))
	local tok = Nexttok(f)
	while tok ~= nil do
		print(tok)
		tok = Nexttok(f)
	end
end

local function whitespace(c)
	if string.match(c, "%s") then
		return true
	else
		return false
	end
end

---comment
---@param file file*
function Nexttok(file)
	local c
	repeat
		c = file:read(1)
		if c == nil then return end
	until not whitespace(c)
	local token = ''
	repeat
		token = token .. c
		c = file:read(1)
		if c == nil then return end
	until whitespace(c)
	return token
end

Main()
