local ansi = require('ansi').ansi

local mod = {}

local function whitespace(c)
	if string.match(c, "%s") then
		return true
	else
		return false
	end
end

local parser = {}
parser._mt = { __index = parser }

function parser.new(str)
	local t = {
		str=str,
	}
	return setmetatable(t, parser._mt)
end

mod.parser = parser

local yield = coroutine.yield
local function nop() end
local function set(t)
	return function(...)
		for i = 1, select('#',...) do
			t[i] = select(i, ...)
		end
	end
end

local function yieldwty(ty)
	return function(...)
		yield{type=ty, ...}
	end
end

function parser:match(pat, commit)
	local matches = { string.match(self.ctx.str, pat .. '()') }
	local i = matches[#matches]
	matches[#matches] = nil
	if #matches > 0 then
		commit(unpack(matches))
		self.ctx.str = string.sub(self.ctx.str, i)
		return true
	end
	return false
end

function parser:chunk()

end
function parser:block()
	yield(self:chunk())
end

function parser:stat()

end

function parser:laststat()
	if self:match('return', yieldwty'kw') then
		self:explist()
	elseif self:match('break', yieldwty'kw') then

	end
end

function parser:funcname()
	local ident1 = {}
	if self:match('[%a_][%w_]*', set(ident1)) then
		local ident2 = {}
		if self:match('[:.][%a_][%w_]*', set(ident2)) then
			local ident = ident1[1] .. ident2[1]
			yield{type='ident', ident}
		end
	end
end

function parser:varlist() end

function parser:explist() end

function parser:exp() end

function parser:prefixexp() end

function parser:functioncall() end

function parser:args() end

function parser:func()
	if self:match('function', yieldt1('kw')) then
		yield{'function', 'kw'}
		self:funcbody()
	end
end

function parser:funcbody()
	if string.match(self.ctx.str, '(') then

	end
end

function parser:parlist() end

function parser:tableconstructor() end

function parser:fieldlist() end

function parser:field() end

function parser:fieldsep() end

function parser:binop() end

function parser:unop()
	local ops = {'%-', 'not', '#'}
	for _, v in ipairs(ops) do
		if self:match(v, yieldwty'op') then
			break
		end
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
