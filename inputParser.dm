inputParser
	proc
		parse(Input/I, n)

inputParser/default
	var
		key = ""

	answer_any
		key = "any"
		parse(Input/I, n)
			I.__input = n

	answer_list
		key = "list"
		parse(Input/I, n)
			var/match = FALSE
			var/textCmp = (I.__ignoreCase) ? "cmptext":"cmptextEx"
			for(var/a in I.__answers)
				if(I.__autoComplete)
					match = inputOps.short2full(n, a, I.__ignoreCase)
				else
					match = call(textCmp)(n,a)
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
			if(!n || (inputOps.whitespace(n) == length(n)))
				return new/inputError("Not a number.")
			var/t2n = text2num(n)
			if("[n]" == "[t2n]")
				I.__input = t2n
				return
			else
				return new/inputError("Not a number.")
