inputParser
	proc
		parse(Input/I, n)

inputParser/default
	var
		key = ""

	answer_any
		key = "any"
		parse(Input/I, n)
			if(!I.__allowEmpty && inputOps.isEmpty(n))
				return new/inputError("Please provide a non-empty answer.")
			I.__input = n

	answer_list
		key = "list"
		parse(Input/I, n)
			if(inputOps.isEmpty(n))
				if(I.__defaultAnswer)
					n = I.__defaultAnswer
				else if(!I.__allowEmpty)
					return new/inputError("Invalid choice.")

			var/match = FALSE
			var/list/L = I.__answers.Copy()

			for(var/a in L)
				if(I.__autoComplete)
					match = inputOps.short2full(n, a, I.__ignoreCase)
				else
					if(I.__ignoreCase)
						match = cmptext(n,a)
					else
						match = cmptextEx(n,a)
				if(match)
					n = a
					break

			if(!match)
				return new/inputError("Invalid choice.")
			else
				I.__input = n
				return

	// A more advanced, numbered list.
	answer_numbered_list
		key = "numlist"
		parse(Input/I, n)
			var/match = FALSE
			var/list/L = I.__answers.Copy()

			for(var/a in L)
				if(I.__autoComplete)
					match = inputOps.short2full(n, a, I.__ignoreCase)
				else
					if(I.__ignoreCase)
						match = cmptext(n,a)
					else
						match = cmptextEx(n,a)
				if(match)
					n = a
					break

			if(!match)
				var/n_num = text2num(n)
				if("[n_num]" == "[n]" && n_num >= 1 && n_num <= length(I.__answers))
					I.__input = I.__answers[n_num]
					return
				return new/inputError("Invalid answer.")
			else
				I.__input = n
				return

	answer_yesno
		key = "yesno"
		parse(Input/I, n)
			if(!I.__allowEmpty && inputOps.isEmpty(n))
				return new/inputError("You must answer yes or no.")
			if(inputOps.short2full(n,"yes", 1)) // Always ignore case
				I.__input = "yes"
				return
			else if(inputOps.short2full(n,"no",1)) // always ignore case
				I.__input = "no"
				return
			else
				return new/inputError("Must answer yes or no.")

	answer_num
		key = "num"
		parse(Input/I, n)
			if(!I.__allowEmpty && inputOps.isEmpty(n))
				return new/inputError("Not a number.")
			var/t2n = text2num(n)
			if("[n]" == "[t2n]")
				I.__input = t2n
				return
			else
				return new/inputError("Not a number.")
