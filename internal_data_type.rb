tokenTypes = [
	:number,
	:string,
	:list,
	:symbol,
	:nil,
	:true,
	:false,
	:func,
	:error,
	:def,
	:let,
	:lambda,
	:do,
	:if
]

class IDT

	def initialize(tokenType, tokenValue)
		@type = tokenType
		@value = tokenValue
	end

	def type
		@type
	end

	def value
		@value
	end

end


class InternalFunc

	attr_accessor :body, :params, :scope, :fn, :is_core, :core_func

	def initialize(params, body, env)
		@is_core = false

		@body = body
		@scope = Env.new(env)
		@params = params
	end

	def invoke(args)
		# new env from args
		args.each_with_index do |arg, idx|
			@scope.set(@params[idx], Eval.EVAL(arg, @scope))
		end
	end

	def new_scope(args)
		args.each_with_index do |arg, idx|
			@scope.set(@params[idx], arg)
		end
		@scope
	end

end