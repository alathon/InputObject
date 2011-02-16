inputFormatter
	proc
		send(txt,trg)
		notifyQuestion(Input/I)
		notifyError(Input/I)

	// Default just prints 'as-is'
	default/default
		notifyQuestion(Input/I)
			if(I.getConfirmQuestion() && !I.__confirm)
				send(I.getConfirmQuestion(), I.__target)
			else
				send(I.getQuestion(), I.__target)

		notifyError(Input/I)
			var/inputError/E = I.getError()
			send(E.error, I.__target)
