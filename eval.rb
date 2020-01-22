require_relative "internal_data_type"
require_relative "env"


module Eval

	def Eval.replace_symbols(ast, env)
		if ast.type == :symbol
			if env.get(ast.value).type != :error
				return env.get(ast.value)
			else
				return ast
			end
		elsif ast.type == :list
			return IDT.new(:list, ast.value.map { |a| replace_symbols(a, env) })
		else
			return ast
		end
	end

	special = [:def, :let, :do, :if, :lambda, :func]

	def Eval.EVAL(ast, env)

		while true

			if ast.type != :list
				return Eval.eval_ast(ast, env)
			end

			if ast.value.size == 0
				return IDT.new(:nil, "")
			end

			listValue = ast.value
			first, second, third, fourth = listValue

			if [:number, :error, :nil, :true, :false].include? first.type
				return first
			elsif [:symbol, :list].include? first.type
				evaled = Eval.EVAL(first, env)
				ast = IDT.new(:list, [evaled] + listValue.drop(1))
			else
				case first.type
				when :func

					func = first.value
					if func.is_core
						return first.value.core_func.call *listValue.drop(1).map{ |a| Eval.EVAL(a, env) }
					else
						args = listValue.drop(1).map{ |arg| Eval.EVAL(arg, env) }
						env = func.new_scope(args)
						ast = Eval.replace_symbols(func.body, env)
					end

				when :def

					if second == nil || third == nil
						return IDT.new(:error,
							"def! requires exactly 2 params.")
					end
					set_to = Eval.EVAL(third, env)
					if set_to.type != :error
						env.set(second.value, set_to)
					end
					ast = set_to

				when :let

					let_env = Env.new(env)
					second.value.each_slice(2) do |k, v|
						let_env.set(k.value, Eval.EVAL(v, let_env))
					end
					env = let_env
					ast = third

				when :if

					condition = second
					true_case = third
					false_case = fourth
					if condition
						condition_eval = Eval.EVAL(condition, env)
					else
						return IDT.new(:error, "no condition to evaluate for if statement")
					end

					if (condition_eval.type == :false) || (condition_eval.type == :nil)
						ast = false_case ? false_case : IDT.new(:nil, "")
					else
						ast = true_case ? true_case : IDT.new(:nil, "")
					end

				when :lambda

					if second.type != :list
						return IDT.new(:error, "function missing argument definition")
					end
					if third == nil
						return IDT.new(:error, "function missing body")
					end

					params = second.value.map { |x| x.value }
					body = third
					lambda_func = IDT.new(:func, InternalFunc.new(params, body, env))

					return lambda_func

				when :do

					to_do = listValue.drop(1)
					if to_do.length == 0
						return IDT.new(:nil, "")
					elsif to_do.length == 1
						ast = to_do[0]
					else
						Eval.EVAL(to_do[0], env)
						ast = IDT.new(:list, [IDT.new(:do, "")] + to_do.drop(1))
					end

				else

					return IDT.new(:error, "else branch in eval should not have been hit. Unsupported #{first.type} type")

				end

			end

		end

	end


	def Eval.eval_ast(ast, env)

		case ast.type
		when :symbol
			env.get(ast.value)
		when :list
			Eval.EVAL( IDT.new(:list, ast.value.map { |v| Eval.EVAL(v, env) }), env)
		else
			ast
		end

	end


end