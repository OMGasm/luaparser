local function printf(...) io.write(string.format(...)) end

local mod = {}

function mod.assert_eq(result, expected, message)
	--lil flag to see if the test is "valid"
	__TESTING_ASSERTED=true
	if result ~= expected then
		local msg = string.format("Assert failed: %s\n"..
			"\tGot: %q, Expected: %q\n",
			message, expected, result)
		error(msg, 2)
	end
end

function mod.skip_test()
	__TESTING_SKIP=true
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

local testrunmt = {__index = _G}

local function set_testing_envs(env, test)
	setfenv(mod.assert_eq, env)
	setfenv(mod.skip_test, env)
	setfenv(test, env)
end

function mod.run_tests(tests)
	local ansi = require('ansi').ansi

	printf('Running %d tests\n', #tests)
	local failed = {}
	local ignored = {}
	local skipped = {}
	local env = setmetatable({}, testrunmt)
	for i, test in ipairs(tests) do
		env.__TESTING_SKIP=false
		env.__TESTING_ASSERTED=false
		set_testing_envs(env, test.test)
		local passed, err = pcall(test.test)
		-- setmetatable(env, nil)
		if not passed then
			table.insert(failed, {i=i, name=test.name})
			printf('[%d] %s%q failed%s:\n\t%s%s%s',
				i, ansi 'red', test.name, ansi 'reset',
				ansi 'grey', err, ansi 'reset')
		elseif env.__TESTING_SKIP then
			table.insert(skipped, {i=i, name=test.name})
		elseif not env.__TESTING_ASSERTED then
			table.insert(ignored, {i=i, name=test.name})
		end
	end

	for _, test in ipairs(ignored) do
		printf("\n%sSkipped [%d] %s (did you forget an assert?"..
			" (or explicitly call skip_test()))%s", ansi 'grey', test.i, test.name, ansi 'reset')
	end

	local passed = #tests - #failed - #skipped - #ignored
	local nskipped = #skipped + #ignored
	printf("\nPassed: %d, Failed: %d, Skipped: %d", passed, #failed, nskipped)
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
