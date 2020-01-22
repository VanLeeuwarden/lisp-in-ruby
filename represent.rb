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

class Representation

	def initialize(tokenType, tokenValue)
		@tokenType = tokenType
		@tokenValue = tokenValue
	end

	def repType
		@tokenType
	end

	def repValue
		@tokenValue
	end
	
end