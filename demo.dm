inputFormatter
	send(txt,trg)
		world << txt

client/Command(T)
	if(__target)
		world << "Sending input to Input"
		__target.receiveInput(T)
	else if(hascall(src, T))
		call(src, T)()
	else
		world << "Uncaught: [T]"


client/proc/TestNlist()
	spawn()
		var/question = "#1: Bob\n#2: Joe\n#3: Stephen\nAnswer: "
		var/Input/I = new(question, inputOps.ANSWER_TYPE_NUMLIST)
		I.setAnswerlist(list("bob", "joe", "stephen"))
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/callbackFunc(c, n)
	return new/inputError("Callback failure")

client/proc/TestCallback()
	spawn()
		var/Input/I = new("Callback test",
							inputOps.ANSWER_TYPE_ANY)
		I.setCallback(src, "callbackFunc")
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestConfirm()
	spawn()
		var/Input/I = new("You should confirm this input.", 
						  inputOps.ANSWER_TYPE_ANY)
		I.setConfirm("Confirm what you just typed before, please.")
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestTime()
	spawn()
		var/Input/I = new("You have 3 seconds!",
						  inputOps.ANSWER_TYPE_ANY)
		I.setTimeout(3)
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestCSL()
	spawn()
		var/Input/I = new("Pick from a list",
						  inputOps.ANSWER_TYPE_LIST)
		I.setAnswerlist(list("bob", "joe", "salamander"))
		I.setAutocomplete(TRUE)
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestTry()
	spawn()
		var/Input/I = new("Get it wrong 3 times!",
						  inputOps.ANSWER_TYPE_NUM)
		I.setMaxtries(3)
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestNum()
	spawn()
		var/Input/I = new("Answer with a number",
						  inputOps.ANSWER_TYPE_NUM)
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestYesno()
	spawn()
		var/Input/I = new("Answer yes or no to this question.",
						  inputOps.ANSWER_TYPE_YESNO)
		var/a = I.getInput(src)
		world << "Answer: [a]"

client/proc/TestInput()
	spawn()
		var/Input/I = new("Some Question",
						  inputOps.ANSWER_TYPE_ANY)
		var/a = I.getInput(src)
		world << "Answer: [a]"

