// States:
// inputOps.STATE_READY 	<-- The input object is ready to begin accepting input.
// inputOps.STATE_ACCEPT    <-- The input object is accepting input.
// inputOps.STATE_DONE		<-- The input object is done. (This and above state the same?)
// inputOps.STATE_ERROR		<-- Input was received, and bad.

// Setter-functions for options
Input
	proc
		setAllowempty(n)
			if(__state != inputOps.STATE_READY) return
			__allowEmpty = n

		setDefault(n)
			if(__state != inputOps.STATE_READY) return
			__defaultAnswer = n

		setDelonexit(n)
			if(__state != inputOps.STATE_READY) return
			__delOnExit = n

		setAnswerlist(list/L)
			if(!L || !length(L)) return
			if(__state != inputOps.STATE_READY) return
			__answers = L

		setTimeout(n)
			if(__state != inputOps.STATE_READY) return
			if(!isnum(n)) n = text2num(n)
			__timeout = n

		setConfirm(msg)
			if(__state != inputOps.STATE_READY) return
			if(!msg)
				__confirm = 0
				__confirmQuestion = null
			else
				__confirm = 1
				__confirmQuestion = msg

		setAutocomplete(n)
			if(__state != inputOps.STATE_READY) return
			__autoComplete = n

		setIgnorecase(n)
			if(__state != inputOps.STATE_READY) return
			__ignoreCase = n

		setStrictmode(n)
			if(__state != inputOps.STATE_READY) return
			__strictMode = n

		setMaxtries(n)
			if(__state != inputOps.STATE_READY) return
			if(!isnum(n) || n < 0) return
			__maxTries = n
			if(__maxTries) __strictMode = FALSE

		setCallback(o, n)
			if(__state != inputOps.STATE_READY) return
			if(n)
				if(!hascall(o, n))
					return
				__callback = n
				__callback_obj = o
			else
				__callback = o

Input
	New(__question, __parser, __formatter)
		if(__formatter)
			src.__formatter = inputOps.getFormatter(__formatter)
		else
			src.__formatter = inputOps.getFormatter("default")

		if(__parser)
			src.__parser = inputOps.getParser(__parser)
		else
			src.__parser = inputOps.getParser("any")

		src.__question = __question
		src.__state = inputOps.STATE_READY


	var
		inputFormatter/__formatter
		inputParser/__parser
		client/__target
		inputError/__error
		__loopTime = 2
		__input
		__state
		__question

		// Support variables for parsing options
		list/__answers
		__callback_obj
		__tryCount = 0
		__confirmQuestion
		__confirmWith

		// Options for parsing
		__allowEmpty = FALSE
		__defaultAnswer
		__delOnExit = TRUE
		__callback = null
		__autoComplete = 0 // Don't auto-complete list answers by default
		__timeout = 0
		__maxTries = 0
		__ignoreCase = TRUE// Case sensitive if 0
		__confirm = FALSE // Don't require confirmation by default
		__strictMode = TRUE // Let user re-try bad answers until they get a valid one by default.
						 // Should be set to 0 if __maxTries is non-zero

	proc
		__errorUser()
			__formatter.notifyError(src)

		__questionUser()
			__formatter.notifyQuestion(src)

		__parseInput(n)
			var/inputError/E = __parser.parse(src, n)
			if(!istype(E, /inputError) && __callback)
				if(__callback_obj)
					E = call(__callback_obj, __callback)(__target, __input)
				else
					E = call(__callback)(__target, __input)

			if(!istype(E, /inputError))
				if(__confirmQuestion && !__confirm)
					if(!cmptextEx(__input,__confirmWith))
						E = new/inputError("Confirmation didn't match.")

			if(istype(E, /inputError))
				__state = inputOps.STATE_ERROR
				__error = E

			else
				__state = inputOps.STATE_DONE

		__cleanAndExit()
			if(__target && __target.__target == src)
				__target.__target = null

			__resetTemporaries()
			if(__delOnExit) del src
			else __state = inputOps.STATE_READY

		__timeoutHeartbeat()
			var/n = __timeout
			spawn()
				while(n-- > 0)
					if(__state == inputOps.STATE_ACCEPT)
						sleep(10)
					else
						return

				if(__state == inputOps.STATE_ACCEPT)
					__state = inputOps.STATE_ERROR
					__error = new/inputError("Input timed out")

		copy()
			var/Input/I = new()
			var/list/dont_copy = list("type","parent_type","tag","vars")
			for(var/a in src.vars)
				if(a in dont_copy) continue
				if(istype(src.vars[a], /list))
					var/list/L = src.vars[a]
					I.vars[a] = L.Copy()
				else
					I.vars[a] = src.vars[a]
			return I

		receiveInput(n)
			if(__state != inputOps.STATE_ACCEPT)
				return

			__parseInput(n)

		getError()
			if(__error) return __error

		getQuestion()
			return __question

		getConfirmQuestion()
			return __confirmQuestion

		getInput(client/C)
			if(__state != inputOps.STATE_READY)
				return inputOps.INPUT_NOT_READY
			__state = inputOps.STATE_ACCEPT
			__target = C
			C.__target = src

			if(__timeout)
				__timeoutHeartbeat()

			while(1)
				__questionUser()
				while(__state == inputOps.STATE_ACCEPT)
					sleep(__loopTime)

				if(__state == inputOps.STATE_DONE)
					if(__confirm)
						__confirm = 0 // Don't want to confirm more than once.
						__confirmWith = __input
						__state = inputOps.STATE_ACCEPT
						continue
					break
				else if(__state == inputOps.STATE_ERROR)
					__errorUser()

					if(__maxTries && (++__tryCount < __maxTries))
						__state = inputOps.STATE_ACCEPT
					else
						if(__strictMode)
							__resetTemporaries()
							continue
						else
							__input = inputOps.INPUT_BAD
							break

			spawn()
				__cleanAndExit()
			return __input

		__resetTemporaries()
			if(__confirmQuestion)
				__confirm = TRUE
				__confirmWith = null
			if(__maxTries)
				__tryCount = 0
			if(__timeout)
				__timeoutHeartbeat()
			__state = inputOps.STATE_ACCEPT


