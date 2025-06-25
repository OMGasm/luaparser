#!/usr/bin/env luajit

local function main()
	assert(arg[1], "no args supplied")
	local file = assert(io.open(arg[1]))

	local line = file:read("l")
	if string.match(line, "^#") then
		Printf("%s", TokColor('shebang', line))
	else
		file:seek('set', 0)
		local block = Parse_chunk(file:read('a'))
		print(block)
	end
	local block = Parse_chunk(file:read('a'))
	print(block)
end

local syms = {
	var = '',
	ident = ''
}

local function accept(s, sym)
	if string.match(s, "^(%f[%a].*)") then
		return sym, s
	end
end

local function expect(sym)

end

function Parse_chunk(f)
	return accept(f, 'comment')
end

function Printf(fmt, ...)
	io.write(string.format(fmt, ...))
end

function TokColor(tok, s)
	local colors = {
		shebang = Ansi'grey',
		keyword = Ansi'magenta',
		string = Ansi'green',
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


do
	local ffi = require'ffi'
	ffi.cdef[[ int poll(void*, long, int); ]]
	local int = ffi.typeof'int'

	function Sleep(ms)
		ffi.C.poll(nil, 0, int(ms))
	end
end



ANSI()

main()
