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

---return a function that when called, yields a table with the type `ty` filled in, and the remaining `...` as values
---@param ty string 'type' of value being yielded
---@return fun(...)
local function yieldwty(ty)
	return function(val)
		yield{type=ty, val=val}
	end
end

---match context string against a pattern, then if found, call `commit` with the match(es)
---@param pat string
---@param commit fun(...:string)
---@return boolean
function parser:pmatch(pat, commit)
	local matches = { string.match(self.str, pat .. '()') }
	local i = matches[#matches]
	matches[#matches] = nil
	if #matches > 0 then
		commit(unpack(matches))
		self.str = string.sub(self.str, i)
		return true
	end
	return false
end

---match context string against a string, then if cound, call `commit` with the match
---@param str string
---@param commit fun(str:string)
---@return boolean
function parser:match(str, commit)
	local sub = string.sub(self.str, 1, #str)
	if sub == str then
		commit(sub)
		self.str = string.sub(self.str, #str + 1)
		return true
	end
	return false
end

function parser:many(thing)
	return coroutine.wrap(function()
		local that = thing(self)
		local tok = that()
		while tok do
			yield(tok)
			tok = that()
		end
	end)
end

function parser:ident()
	return coroutine.wrap(function()
		self:pmatch('[%a_][%w_]*', yieldwty 'ident')
	end)
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
	return coroutine.wrap(function()
		local ident1 = {}
		local ident2 = {}
		if not self:pmatch('([%a_][%w_]*)', set(ident1)) then return end
		local ident = ident1[1]
		if self:pmatch('([:.][%a_][%w_]*)', set(ident2)) then
			ident =  ident .. ident2[1]
		end
		yield{type='ident', val=ident}
	end)
end

function parser:varlist() end

function parser:explist() end

function parser:exp() end

function parser:prefixexp() end

function parser:functioncall() end

function parser:args() end

function parser:anon_func()
	return coroutine.wrap(function()
		if self:match('function', yieldwty'kw') then
			for tok in self:funcbody() do
				yield(tok)
			end
		end
	end)
end

function parser:funcbody()
	return coroutine.wrap(function()
		if not self:pmatch('%s*(%()', yieldwty'call') then return end
		for x in self:many(self.ident) do
			yield(x)
		end
		if not self:pmatch('%s*(%))', yieldwty'call') then return end
		if not self:pmatch('%s*(end)', yieldwty 'kw') then return end
	end)
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
		if self:pmatch(v, yieldwty'op') then
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
