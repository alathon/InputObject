inputFormatter
	proc
		send(txt)
		notifyQuestion(Input/I)
		notifyError(Input/I)

	// Default just prints 'as-is'
	default
		proc
			formatList(list/A)
				. = ""
				var/count = 1
				for(var/a in A)
					. += "#[count++] [a]\n"

		notifyQuestion(Input/I)
			var/actual
			if(I.getConfirmQuestion() && !I.__confirm)
				actual = I.getConfirmQuestion()
			else
				actual = I.getQuestion()

			send(actual)

			// Special display code for lists.
			// Either this is the first time we're asking in a confirm-situation,
			// or there isn't a confirm situation. We want to avoid sending the special
			// list view to the user twice.
			if(istype(I.__parser, /inputParser/default/answer_list))
				if((I.getConfirmQuestion() && I.__confirm) || !I.getConfirmQuestion())
					if(!length(I.__answers))
						send("No answers to pick from! Sorry!")
					else
						send(formatList(I.__answers))

		notifyError(Input/I)
			var/inputError/E = I.getError()
			world << E.error
