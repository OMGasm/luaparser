local ansi = require('ansi').ansi

local mod = {}

local function whitespace(c)
	if string.match(c, "%s") then
		return true
	else
		return false
	end
end

---comment
---@param file file*
function mod.Nexttok(file)
	local c
	local lf = false
	repeat
		c = file:read(1)
		if c == nil then
			return
		elseif c == '\n' then
			lf = true
		end
	until not whitespace(c)
	local token = ''
	repeat
		token = token .. c
		c = file:read(1)
		if c == nil then return end
	until whitespace(c)
	file:seek("cur", -1)
	return token, lf
end

function mod.TokClassifier(tok)
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

function mod.TokColor(tok, s)
	local colors = {
		shebang = ansi'grey',
		keyword = ansi'magenta',
		string = ansi'green',
		unknown = '',
	}
	local col = colors[tok]
	return string.format("%s%s%s", col, s, ansi'reset')
end

return mod
