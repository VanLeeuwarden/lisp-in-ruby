require_relative "internal_data_type"


class Env

	attr_reader :thisEnv
	
	def initialize(outerEnv=nil, binds=[], exprs=[])
		@outerEnv = outerEnv
		@thisEnv = {}
	end

	def set(key, value)
		@thisEnv[key] = value
	end

	def find_env(key)

		if @thisEnv.key? key
			@thisEnv
		elsif @outerEnv == nil
			nil
		else
			@outerEnv.find_env key
		end

	end

	# returns value/error
	def get(key)

		thisEnvValue = @thisEnv[key]

		if thisEnvValue != nil
			thisEnvValue
		elsif @outerEnv == nil
			IDT.new(:error, "symbol #{key} is not defined")
		else
			@outerEnv.get(key)
		end

	end

end

def baseEnv

	def number_convert_errors(args)
		errors = args.select { |n| n.type != :number }
		if errors.size > 0
			err_messages = errors.map { |e| "\n #{e.type} #{e.value}"}
			IDT.new(:error,
				"The following could not be treated as numbers:" + err_messages.join(","))
		end
	end

	def recursive_equality(x, y)

		if x.type != y.type
			false

		elsif x.type == :list
			if x.value.size != y.value.size
				false

			else
				x.value.each_with_index do |x_element, index|
					y_element = y.value[index]
					eq = recursive_equality(x_element, y_element)
					if not eq 
						false
					end
				end
				true

			end

		else
			x.value == y.value

		end

	end

	def create_core(lmda)
		f = IDT.new(:func, InternalFunc.new(nil, nil, nil))
		f.value.is_core = true
		f.value.core_func = lmda
		f
	end

	plus = create_core( 
		lambda do |*args| 
			n_err = number_convert_errors(args)
			if n_err
				n_err
			else
				numbers = args.map { |n| n.value }
				IDT.new(:number, numbers.sum())
			end
		end)

	minus = create_core( 
		lambda do |*args|
			n_err = number_convert_errors(args)
			if n_err
				n_err
			else
				numbers = args.map { |n| n.value }
				IDT.new(:number, numbers.first - numbers.drop(1).sum )
			end
		end)

	times = create_core(
		lambda do |*args|
			n_err = number_convert_errors(args)
			if n_err
				n_err
			else
				numbers = args.map { |n| n.value }
				prod = 1
				numbers.each { |n| prod = prod * n }
				IDT.new(:number, prod)
			end
		end)


	divide = create_core(
		lambda do |x, y|
			if y == 0
				IDT.new(:error, "division by zero")
			end
			IDT.new(:number, x / y )
		end)

	new_list = create_core(
		lambda { |*args| IDT.new(:list, args)})

	is_list = create_core(
		lambda do |l|
			if l.type == :list
				IDT.new(:true, "true")
			else
				IDT.new(:false, "false")
			end
		end)

	is_empty = create_core(
		lambda do |l|
			if l.type != :list
				IDT.new(:error, "empty? can only be applied to a list")
			elsif l.value.size > 0
				IDT.new(:false, "false")
			else
				IDT.new(:true, "true")
			end
		end)

	count = create_core(
		lambda do |l|
			case l.type
			when :nil
				IDT.new(:number, 0)
			when :list
				IDT.new(:number, l.value.size)
			else IDT.new(:error, "empty? can only be applied to a list or nil") 
			end
		end)

	equal = create_core(
		lambda do |x, y|
			case recursive_equality x,y
			when true
				IDT.new(:true, "true")
			when false
				IDT.new(:false, "false")
			else
				IDT.new(:error, "equality operation did not return value")
			end
		end)

	greater = create_core(
		lambda do |x, y|
			n_err = number_convert_errors [x,y]
			if n_err
				return n_err
			else
				compare = x.value > y.value
				case compare
				when true
					IDT.new(:true, "true")
				else
					IDT.new(:false, "false")
				end
			end
		end)

	greater_equal = create_core(
		lambda do |x, y|
			n_err = number_convert_errors [x,y]
			if n_err
				return n_err
			else
				compare = x.value >= y.value
				case compare
				when true
					IDT.new(:true, "true")
				else
					IDT.new(:false, "false")
				end
			end
		end)

	less = create_core(
		lambda do |x, y|
			n_err = number_convert_errors [x,y]
			if n_err
				return n_err
			else
				compare = x.value < y.value
				case compare
				when true
					IDT.new(:true, "true")
				else
					IDT.new(:false, "false")
				end
			end
		end)

	less_equal = create_core(
		lambda do |x, y|
			n_err = number_convert_errors [x,y]
			if n_err
				return n_err
			else
				compare = x.value <= y.value
				case compare
				when true
					IDT.new(:true, "true")
				else
					IDT.new(:false, "false")
				end
			end
		end)


	env = Env.new(nil)
	env.set("+", plus)
	env.set("-", minus)
	env.set("*", times)
	env.set("/", divide)
	env.set("list", new_list)
	env.set("list?", is_list)
	env.set("empty?", is_empty)
	env.set("count", count)
	env.set("=", equal)
	env.set(">", greater)
	env.set(">=", greater_equal)
	env.set("<", less)
	env.set("<=", less_equal)

	return env
end