local testing = require('testing')
local assert_eq = testing.assert_eq

testing.catch_unset_globals()

local parser = require('parser').parser

---@diagnostic disable: lowercase-global
local tests = testing.add_tests(function()
	function basic_funcname()
		local p = parser.new("foo()")
		local token = p:funcname()()
		assert_eq('ident', token.type, "Expected name")
		assert_eq('foo', token.val, "should get foo")
	end

	function table_dot_funcname()
		local p = parser.new("tablefoo.bar()")
		local token = p:funcname()()
		assert_eq('ident', token.type, "Expected name")
		assert_eq('tablefoo.bar', token.val, "expected table.func name")
	end
end)
---@diagnostic enable: lowercase-global

testing.run_tests(tests)
