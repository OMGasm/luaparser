local function printf(...) io.write(string.format(...)) end

local mod = {}

function mod.assert_eq(result, expected, message)
	if result ~= expected then
		local msg = string.format("Assert failed: %s\n"..
			"\tGot: %q, Expected: %q\n",
			message, expected, result)
		error(msg, 2)
	end
end

function mod.catch_unset_globals()
	setmetatable(_G, {__index = function(_, k)
		local name = debug.getinfo(2, "n").name
		local msg
		if name then
			msg = string.format('%q tried to access an unset global [%q]', name..'()', k)
		else
			msg = string.format('Something tried to access an unset global [%q]', k)
		end
		error(msg, 2)
	end })
end

function mod.run_tests(tests)
	local ansi = require('ansi').ansi

	printf('Running %d tests\n', #tests)
	local failed = {}
	for i, test in ipairs(tests) do
		local passed, err = pcall(test.test)
		if not passed then
			table.insert(failed, {i=i, name=test.name})
			printf('[%d] %s%q failed%s:\n\t%s%s%s',
				i, ansi 'red', test.name, ansi 'reset',
				ansi 'grey', err, ansi 'reset')
		end
	end

end

local testmt = {__index = _G}
function testmt:__newindex(k, v)
	rawset(self, #self+1, {name=k, test=v})
end

function mod.add_tests(tests_func)
	local tests = setmetatable({}, testmt)
	setfenv(tests_func, tests)()
	return tests
end


return mod
