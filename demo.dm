#define DEMO_MODE
#ifdef DEMO_MODE
inputOptions
	New()
		..()
		addParser("any", /inputParser/default/answer_any)
		addParser("list", /inputParser/default/answer_list)
Input
	New(q, ip, formatter)
		__state = inputOps.STATE_READY
		__parser = inputOps.getParser(ip) || inputOps.getParser("any")
		__formatter = inputOps.getFormatter(formatter) || inputOps.getFormatter("default")
		__question = q

client/Command(T)
	if(__target)
		world << "Sending input to Input"
		__target.receiveInput(T)
	else if(hascall(src, T))
		call(src, T)()
	else
		world << "Uncaught: [T]"

client/proc/TestYesno()
	spawn()
		var/Input/I = new("Answer yes or no to this question.", "yesno")
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestInput()
	spawn()
		var/Input/I = new("Some Question", "any")
		var/a = I.getInput(src)
		world << "Answer: [a]"
#endif
