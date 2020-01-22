require_relative "internal_data_type"

class Read

	@@specials = {
		"def!" => IDT.new(:def, "def!"),
		"let*" => IDT.new(:let, "let*"),
		"true" => IDT.new(:true, "true"),
		"false" => IDT.new(:false, "false"),
		"nil" => IDT.new(:nil, "nil"),
		"if" => IDT.new(:if, ""),
		"do" => IDT.new(:do, ""),
		"fn*" => IDT.new(:lambda, "")
	}

	def initialize(input)
		matches = input.scan(/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)/)
		@tokens = matches.flatten.select { |m| m != "" }
		@index = 0
	end

	def peek()
		@tokens[@index]
	end

	def advance()
		@index += 1
	end

	def next_token()
		current_index = @index
		@index += 1
		@tokens[current_index]
	end

	def read_atom(token)
		if @@specials.key?(token)
			return @@specials[token]
		elsif token.match?(/^-?\d+/)
			return IDT.new(:number, token.to_i)
		elsif token.match?(/[a-zA-Z\-+*\/=><]+/)
			return IDT.new(:symbol, token)
		else
			return IDT.new(:error, "malformed symbol #{token}")
		end
	end

	def read_form(current_token)
		case current_token
		when nil
			[]
		when "("
			advance()
			read_list()
		else
			read_atom(current_token)
		end
	end

	def read_list()
		listValues = []
		spotlight = peek()

		while spotlight != ")"
			if spotlight == nil
				listValues << IDT.new(:error, "unclosed parens")
				break
			end
			listValues << read_form(spotlight)
			advance()
			spotlight = peek()
		end
		IDT.new(:list, listValues)
	end

	def return_ast()
		read_form(peek())
	end
	
end
