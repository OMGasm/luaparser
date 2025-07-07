#!/usr/bin/env luajit

function Main()
	assert(arg[1])
	local f = assert(io.open(arg[1]))
	local tok = Nexttok(f)
	while tok ~= nil do
		local cl = TokClassifier(tok)
		local o = TokColor(cl, tok)
		print(o)
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

function TokClassifier(tok)
	local toks = {
		["function"] = 'keyword',
		["local"] = 'keyword',
		["repeat"] = 'keyword',
		["until"] = 'keyword',
		["if"] = 'keyword',
		["then"] = 'keyword',
		["end"] = 'keyword',
		["for"] = 'keyword',
		["in"] = 'keyword',
		["do"] = 'keyword',
		["return"] = 'keyword',
		["and"] = 'keyword',
		["or"] = 'keyword',
		["not"] = 'keyword',
		["while"] = 'keyword',
	}
	return toks[tok] or 'unknown'
end

function TokColor(tok, s)
	local colors = {
		shebang = Ansi'grey',
		keyword = Ansi'magenta',
		string = Ansi'green',
		unknown = '',
	}
	local col = colors[tok]
	return string.format("%s%s%s", col, s, Ansi'reset')
end

function ANSI()
	local codes = {}
	local brights = {gray = 90, grey = 90}
	local basic = {
		black=30,
		red=31,
		green=32,
		yellow=33,
		blue=34,
		magenta=35,
		cyan=36,
		white=37,
	}

	ForEach(basic, function(v, k)
		brights["bright_"..k] = v + 60
		codes[k] = v
	end)

	ForEach(brights, function(v, k)
		codes[k.."_bg"] = v + 10
		codes[k] = v
	end)

	codes.reset = 0

	ANSI = codes
end

function Ansi(q)
	return string.format("\027[%dm", ANSI[q])
end

function Map(t, f)
	local c = {}
	for k, v in type(t) == "table" and pairs(t) or t do
		c[k] = f(v, k, t)
	end
	return c
end

function ForEach(t, f)
	for k, v in pairs(t) do
		f(v, k, t)
	end
	return t
end
ANSI()
Main()
