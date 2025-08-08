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

	function table_colon_funcname()
		local p = parser.new("tablefoo:bar()")
		local token = p:funcname()()
		assert_eq('ident', token.type, "expected name")
		assert_eq("tablefoo:bar", token.val, "expected table:func name")
	end
	function empty_anon_funcs()
		local defs = {
			"function()end",
			"function () end",
			"function   ( \t )\tend",
		}
		local expected = {
			{ type='kw', val='function' },
			{ type='call', val='(' },
			{ type='call', val=')' },
			{ type='kw', val='end' },
		}
		for i, def in ipairs(defs) do
			local p = parser.new(def)
			local j = 1
			for token in p:anon_func() do
				assert_eq(expected[j].type, token.type, 'type: ' .. def)
				assert_eq(expected[j].val, token.val, 'val: ' .. def)
				j = j + 1
			end
			assert_eq(4, j-1, 'token length: ' .. def)
		end
	end

	function empty_wparam_anon_func()
		local p = parser.new("function(foo) end")
		local expected = {
			{ type='kw', val='function' },
			{ type='call', val='(' },
			{ type='ident', val='foo' },
			{ type='call', val=')' },
			{ type='kw', val='end' },
		}
		local i = 1
		for token in p:anon_func() do
			assert_eq(expected[i].type, token.type)
			assert_eq(expected[i].val, token.val)
		end
		assert_eq(5, i-1, 'token length')
	end

	function basic_wparam_anon_func()
		local p = parser.new("function(foo, bar) baz() end")
		local expected = {
			{ type='kw', val='function' },
			{ type='call', val='(' },
			{ type='ident', val='foo' },
			{ type='sep', val=',' },
			{ type='ident', val='foo' },
			{ type='call', val=')' },
			{ type='ident', val='baz' },
			{ type='call', val='(' },
			{ type='call', val=')' },
			{ type='kw', val='end' },
		}
	end
end)
---@diagnostic enable: lowercase-global

testing.run_tests(tests)
