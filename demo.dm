Input
	New(q, ip, formatter)
		__state = inputOps.STATE_READY
		__parser = inputOps.getParser(ip) || inputOps.getParser("any")
		__formatter = inputOps.getFormatter(formatter) || inputOps.getFormatter("default")
		__question = q

inputFormatter
	send(txt)
		world << txt

client/Command(T)
	if(__target)
		world << "Sending input to Input"
		__target.receiveInput(T)
	else if(hascall(src, T))
		call(src, T)()
	else
		world << "Uncaught: [T]"

client/proc/TestConfirm()
	spawn()
		var/Input/I = new("You should confirm this input.", "any")
		// Suggested replacement API:
		//I.setConfirm("Confirm what you just typed before, please.")
		I.__confirm = 1
		I.__confirmQuestion = "Confirm what you just typed before, please."
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestTime()
	spawn()
		var/Input/I = new("You have 3 seconds!", "any")
		// Suggested replacement API:
		//I.setTimeout(3)
		I.__timeout = 3
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestCSL()
	spawn()
		var/Input/I = new("Pick from a list", "list")
		I.__answers = list("bob","joe","salamander")
		I.__autoComplete = 1
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestTry()
	spawn()
		var/Input/I = new("Get it wrong 3 times!", "num")
		// Suggested replacement API:
		//I.setMaxTries(3)
		I.__maxTries = 3
		I.__strictMode = 0 // Set strictMode off
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestNum()
	spawn()
		var/Input/I = new("Answer with a number", "num")
		var/a = I.getInput(src)
		world << "Answer: [a]"

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

