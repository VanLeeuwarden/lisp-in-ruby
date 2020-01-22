require_relative "read"
require_relative "eval"
require_relative "print"

class REPL

	attr_reader :env
	
	def initialize(env)
		@env = env
	end

	def input(raw_string)
		ast = Read.new(raw_string).return_ast()
		val = Eval.EVAL(ast, @env)
		Print.printer val
	end

end