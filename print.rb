module Print

	BASIC_PRINT = [:string, :symbol]

	def Print.printer(rep)
		if BASIC_PRINT.include?(rep.type)
			rep.value
		else 
			case rep.type
			when :number
				rep.value.to_s
			when :error
				"Error: " + rep.value
			when :list
				innerPrint = rep.value.map { |r| printer r }
				"(" + innerPrint.join(" ") + ")"
			when :def
				"def! (should not have been printed)"
			when :let
				"let* (should not have been printed)"
			when :do
				"do (should not have been printed)"
			when :func
				"#<Function>"
			when :nil
				"nil"
			when :true
				"true"
			when :false
				"false"
			when :lambda
				"fn*"
			when :if
				"if"
			else
				"UNRECOGNIZED TOKEN TYPE #{rep.type}"
			end
		end
	end

end