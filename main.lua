#!/usr/bin/env luajit
local parser = require('parser')
local Nexttok, TokColor, TokClassifier = parser.Nexttok, parser.TokColor, parser.TokClassifier

function Main()
	assert(arg[1])
	local f = assert(io.open(arg[1]))
	local tok, lf = Nexttok(f)
	while tok ~= nil do
		local cl = TokClassifier(tok)
		local o = TokColor(cl, tok)
		io.write(lf and '\n' or '', o, ' ')
		tok, lf = Nexttok(f)
	end
end

Main()
