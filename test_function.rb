require "test/unit"

require_relative "read"
require_relative "eval"
require_relative "print"
require_relative "env"
require_relative "repl"

def base_repl
	env = baseEnv()
	REPL.new(env)
end

class ListFunctions < Test::Unit::TestCase

	def setup
		@repl = base_repl
	end

	def test_empty_list
		output = @repl.input "(list)"
		assert_equal "()", output
	end

	def test_is_list
		output = @repl.input "(list? (list))"
		assert_equal "true", output
	end

	def test_is_empty
		output = @repl.input "(empty? (list 1))"
		assert_equal "false", output
	end

	def test_list_create
		output = @repl.input "(list 1 2 3)"
		assert_equal "(1 2 3)", output
	end

	def test_count
		output = @repl.input "(count (list 1 2 3))"
		assert_equal "3", output
	end

	def test_count_empty
		output = @repl.input "(count (list))"
		assert_equal "0", output
	end

	def test_count_nil
		output = @repl.input "(count nil)"
		assert_equal "0", output
	end

	def test_strict_greater
		output = @repl.input "(if (> (count (list 1 2 3)) 3) 89 78)"
		assert_equal "78", output
	end

	def test_greater_equal
		output = @repl.input "(if (>= (count (list 1 2 3)) 3) 89 78)"
		assert_equal "89", output
	end

end


class IfForm < Test::Unit::TestCase

	def setup
		@repl = base_repl()
	end

	def test_basic1
		output = @repl.input "(if true 7 8)"
		assert_equal "7", output
	end

	def test_basic2
		output = @repl.input "(if false 7 8)"
		assert_equal "8", output
	end

	def test_nestsed1
		output = @repl.input "(if true (+ 1 7) (+ 1 8))"
		assert_equal "8", output
	end

	def test_nested2
		output = @repl.input "(if false (+ 1 7) (+ 1 8))"
		assert_equal "9", output
	end

	def test_nil
		output = @repl.input "(if nil 7 8)"
		assert_equal "8", output
	end

	def test_zero
		output = @repl.input "(if 0 7 8)"
		assert_equal "7", output
	end

	def test_empty_list
		output = @repl.input "(if (list) 7 8)"
		assert_equal "7", output
	end

	def test_nonempty_list
		output = @repl.input "(if (list 1 2 3) 7 8)"
		assert_equal "7", output
	end

	def test_one_sided
		output = @repl.input "(if false (+ 1 7))"
		assert_equal "nil", output
	end

	def test_nil_one_sided
		output = @repl.input "(if nil 8)"
		assert_equal "nil", output
	end

	def test_nested_one_sided
		output = @repl.input "(if true (+ 1 7))"
		assert_equal "8", output
	end

end

class Conditionals < Test::Unit::TestCase

	def setup
		@repl = base_repl()
	end

	def expected_actual(expected, actual)
		output = @repl.input actual
		assert_equal expected, output
	end

	# Equality

	def test_eq1
		expected_actual "false", "(= 2 1)"
	end

	def test_eq2
		expected_actual "true", "(= 1 1)"
	end

	def test_eq3
		expected_actual "false", "(= 1 2)"
	end

	def test_eq4
		expected_actual "false", "(= 1 (+ 1 1))"
	end

	def test_eq5
		expected_actual "true", "(= 2 (+ 1 1))"
	end

	def test_eq6
		expected_actual "false", "(= nil 1)"
	end

	def test_eq7
		expected_actual "true", "(= nil nil)"
	end

	def test_eq8
		expected_actual "true", "(= true true)"
	end

	def test_eq9
		expected_actual "true", "(= false false)"
	end

	def test_eq10
		expected_actual "true", "(= (list) (list))"
	end

	def test_eq11
		expected_actual "true", "(= (list 1 2) (list 1 2))"
	end

	def test_eq12
		expected_actual "false", "(= (list 1) (list))"
	end

	def test_eq13
		expected_actual "false", "(= (list) (list 1))"
	end

	def test_eq14
		expected_actual "false", "(= 0 (list))"
	end

	def test_eq15
		expected_actual "false", "(= (list) 0)"
	end

	def test_eq16
		expected_actual "false", "(= (list nil) (list))"
	end

	# Greater Than

	def test_gt1
		expected_actual "true", "(> 2 1)"
	end

	def test_gt2
		expected_actual "false", "(> 1 1)"
	end

	def test_gt3
		expected_actual "false", "(> 1 2)"
	end

	# Greater Or Equal

	def test_ge1
		expected_actual "true", "(>= 2 1)"
	end

	def test_ge2
		expected_actual "true", "(>= 1 1)"
	end

	def test_ge3
		expected_actual "false", "(>= 1 2)"
	end

	# Less Than

	def test_l1
		expected_actual "false", "(< 2 1)"
	end

	def test_l2
		expected_actual "false", "(< 1 1)"
	end

	def test_l3
		expected_actual "true", "(< 1 2)"
	end

	# Less Or Equal

	def test_le1
		expected_actual "false", "(<= 2 1)"
	end

	def test_le2
		expected_actual "true", "(<= 1 1)"
	end

	def test_le3
		expected_actual "true", "(<= 1 2)"
	end

end


class LetForm < Test::Unit::TestCase

	def setup
		@repl = base_repl()
	end

	def test_basic
		output = @repl.input "(let* (q 9) q)"
		assert_equal "9", output
	end

	def test_expression
		output = @repl.input "(let* (q (* 3 3)) q)"
		assert_equal "9", output
	end

end



class FuncTests < Test::Unit::TestCase
	
	def setup
		@repl = base_repl()
	end

	def test_func_defined
		output = @repl.input "(fn* (a) a)"
		assert_equal "#<Function>", output
	end

	def test_simple
		output = @repl.input "( (fn* (a) a) 7)"
		assert_equal "7", output
	end

	def test_computation
		output = @repl.input "( (fn* (a) (+ a 1)) 10)"
		assert_equal "11", output
	end

	def test_multiple_args
		output = @repl.input "( (fn* (a b) (+ a b)) 2 3)"
		assert_equal "5", output
	end

	def test_no_args
		output = @repl.input "( (fn* () 4) )"
		assert_equal "4", output
	end

	def test_nested
		output = @repl.input "( (fn* (f x) (f x)) (fn* (a) (+ 1 a)) 7)"
		assert_equal "8", output
	end

end

class Closures < Test::Unit::TestCase

	def setup
		@repl = base_repl()
	end

	def test_closure1
		@repl.input "(def! gen-plus5 (fn* () (fn* (b) (+ 5 b))))"
		@repl.input "(def! plus5 (gen-plus5))"
		output = @repl.input "(plus5 7)"
		assert_equal "12", output
	end

	def test_closure2
		@repl.input "(def! gen-plusX (fn* (x) (fn* (b) (+ x b))))"
		@repl.input "(def! plus7 (gen-plusX 7))"
		output = @repl.input "(plus7 8)"
		assert_equal "15", output
	end

	def test_fibonacci
		@repl.input "(def! fib (fn* (N) (if (= N 0) 1 (if (= N 1) 1 (+ (fib (- N 1)) (fib (- N 2)))))))"

		fib1 = @repl.input "(fib 1)"
		assert_equal "1", fib1

		fib2 = @repl.input "(fib 2)"
		assert_equal "2", fib2

		fib3 = @repl.input "(fib 3)"
		assert_equal "3", fib3

		fib4 = @repl.input "(fib 4)"
		assert_equal "5", fib4
	end

	def test_recursion_in_env
		output1 = @repl.input "(let* (cst (fn* (n) (if (= n 0) nil (cst (- n 1))))) (cst 1))"
		assert_equal "nil", output1

		output2 = @repl.input "(let* (f (fn* (n) (if (= n 0) 0 (g (- n 1)))) g (fn* (n) (f n))) (f 2))"
		assert_equal "0", output2
	end

end

class DoForm < Test::Unit::TestCase

	def setup
		@repl = base_repl()
	end

	def expected_actual(expected, actual)
		output = @repl.input actual
		assert_equal expected, output
	end

	def test_single_value
		expected_actual "7", "(do 7)"
	end

	def test_nil
		expected_actual "nil", "(do)"
	end

	def test_def
		expected_actual "14", "(do (def! a 6) 7 (+ a 8))"
	end

end

class Recursive < Test::Unit::TestCase

	def setup
		@repl = base_repl()
	end

	def test_rec1
		@repl.input "(def! sum2 (fn* (n acc) (if (= n 0) acc (sum2 (- n 1) (+ n acc)))))"
		output = @repl.input "(sum2 10 0)"
		assert_equal "55", output
	end

	def test_rec2
		@repl.input "(def! sum2 (fn* (n acc) (if (= n 0) acc (sum2 (- n 1) (+ n acc)))))"

		output1 = @repl.input "(def! res2 nil)"
		assert_equal "nil", output1

		output2 = @repl.input "(def! res2 (sum2 10000 0))"
		@repl.input "res2"
		assert_equal "50005000", output2
	end

	def test_mutual_recursion
		@repl.input "(def! foo (fn* (n) (if (= n 0) 0 (bar (- n 1)))))"
		@repl.input "(def! bar (fn* (n) (if (= n 0) 0 (foo (- n 1)))))"
		output = @repl.input "(foo 10000)"
		assert_equal "0", output
	end

end
