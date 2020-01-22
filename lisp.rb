require_relative "env"
require_relative "repl"

# initialize repl with env and basic arithmetic functions
env = baseEnv()
repl = REPL.new(env)


puts "start yer ruby lispin'"
while true
	print "\n>> "

	input = gets
	input = input.chomp
	if input == "quit"
		break
	end

	output = repl.input input
	print ";=> "
	print output
end