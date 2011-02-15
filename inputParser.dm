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
					match = Short2Full(n, a, I.__ignoreCase)
				else
					match = call(textCmp)(n,a)
				if(match)
					n = a
					break

			if(!match)
				return new/inputError("Invalid answer.")
			else
				I.__input = n
				return

	answer_yesno
		key = "yesno"
		parse(Input/I, n)
			if(Short2Full(n,"yes", 1)) // Always ignore case
				I.__input = "yes"
				return
			else if(Short2Full(n,"no",1)) // always ignore case
				I.__input = "no"
				return
			else
				return new/inputError("Must answer yes or no.")

	answer_num
		key = "num"
		parse(Input/I, n)
			var/t2n = text2num(n)
			if("[n]" == "[t2n]")
				I.__input = t2n
				return
			else
				return new/inputError("Not a number.")
