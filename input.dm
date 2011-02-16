// States:
// inputOps.STATE_READY 	<-- The input object is ready to begin accepting input.
// inputOps.STATE_INIT  	<-- The input object is setting up, and is not yet ready.
// inputOps.STATE_ACCEPT    <-- The input object is accepting input.
// inputOps.STATE_DONE		<-- The input object is done. (This and above state the same?)
// inputOps.STATE_ERROR		<-- Input was received, and bad.

Input
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
		__callback = null
		__autoComplete = 0 // Don't auto-complete list answers by default
		__timeout = 0
		__maxTries = 0
		__ignoreCase = 1// Case sensitive if 0
		__confirm = 0 // Don't require confirmation by default
		__strictMode = 1 // Let user re-try bad answers until they get a valid one by default.
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
					E = call(__callback_obj, __callback)(__input)
				else
					E = call(__callback)(__input)

			if(__confirmQuestion && !__confirm)
				if(!cmptextEx(__input,__confirmWith))
					E = new/inputError("Confirmation didn't match.")

			if(istype(E, /inputError))
				__state = inputOps.STATE_ERROR
				__error = E
				world << "Error state: [E.error]"

			else
				__state = inputOps.STATE_DONE

		__cleanAndExit()
			if(__target && __target.__target == src)
				__target.__target = null

			world << "DEBUG: Cleaning up and returning input"
			del src

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

		receiveInput(n)
			if(__state != inputOps.STATE_ACCEPT)
				world << "DEBUG: receiveInput([n]): Not ready to accept input"
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
				world << "DEBUG: getInput(): Not in STATE_READY, quitting"
				return

			__state = inputOps.STATE_ACCEPT
			__target = C
			C.__target = src
			world << "DEBUG: getInput(): __state = inputOps.STATE_ACCEPT"

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
							__input = inputOps.BAD_INPUT
							break

			spawn()
				__cleanAndExit()
			return __input

		__resetTemporaries()
			if(__confirmQuestion)
				__confirm = 1
				__confirmWith = null
			if(__maxTries)
				__tryCount = 0
			if(__timeout)
				__timeoutHeartbeat()
			__state = inputOps.STATE_ACCEPT


