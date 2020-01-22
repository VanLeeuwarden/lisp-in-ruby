require "test/unit"

require_relative "read"
require_relative "eval"
require_relative "print"
require_relative "env"
require_relative "repl"

def read_print(input)
	Print.printer(Read.new(input).return_ast())
end

def read_eval_print(input)
	env = baseEnv()
	r = Read.new(input).return_ast()
	e = Eval.EVAL(r, env)
	Print.printer(e)
end

def base_repl
	env = baseEnv()
	REPL.new(env)
end

class ReadPrintTests < Test::Unit::TestCase

	def test1
		assert_equal "123",read_print("123")
	end

	def test2
		assert_equal "123", read_print("123 ")
	end

	def test3
		assert_equal "abc", read_print("abc")
	end

	def test4
		assert_equal "abc",read_print("abc ")
	end

	def test5
		assert_equal "true", read_print("true")
	end

	def test6
		assert_equal "false", read_print("false")
	end

	def test7
		assert_equal "nil", read_print("nil")
	end

	def test8
		assert_equal "(123 456)", read_print("(123 456)")
	end

	def test9
		assert_equal "(+ 2 (* 3 4))", read_print("( + 2 (* 3 4) )")
	end

end

class EvalTests < Test::Unit::TestCase

	def setup
		@repl = base_repl
	end

	def test_eval_simple
		output = @repl.input "10"
		assert_equal "10", output
	end

	def test_eval_nothing
		output = @repl.input "()"
		assert_equal "nil", output
	end

	def test_eval_sum
		output = @repl.input "(+ 2 3)"
		assert_equal "5", output
	end

	def test_eval_minus
		output = @repl.input "(- 3 2)"
		assert_equal "1", output
	end

	def test_eval_nested
		output = @repl.input "(+ 2 (* 3 4))"
		assert_equal "14", output
	end

end

class EnvTests < Test::Unit::TestCase

	def setup
		@repl = base_repl
	end

	def test_def
		output1 = @repl.input "(def! a 6)"
		assert_equal "6", output1

		output2 = @repl.input "a"
		assert_equal "6", output2

		output3 = @repl.input "(def! b (+ a 2))"
		assert_equal "8", output3

		output4 = @repl.input "(+ a b)"
		assert_equal "14", output4
	end

	def test_let1
		output = @repl.input "(let* (c 2) c)"
		assert_equal "2", output
	end

	def test_let2
		output = @repl.input "(let* (c 2 d c) d)"
		assert_equal "2", output
	end

end
