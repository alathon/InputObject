var/inputOptions/inputOps = new()

inputOptions
	New()
		..()
		for(var/a in typesof(/inputParser/default) - /inputParser/default)
			var/inputParser/default/P = new a()
			addParser(P.key, P)
		addFormatter("default", /inputFormatter/default/default)

	proc
		isEmpty(n)
			if(!n || whitespace(n) == length(n)) return 1
			return 0

		short2full(short, full, ignorecase = 1)
			if(!short) return 0

			if(ignorecase)
				return (cmptext(short, copytext(full,1,length(short)+1)))
			else
				return (cmptextEx(short, copytext(full,1,length(short)+1)))

		whitespace(n)
			. = 0
			for(var/a = 1 to length(n))
				if(text2ascii(copytext(n,a,a+1)) == 32) .++

		addParser(key, path)
			if(key in __inputParsers) return 0
			if(istype(path, /inputParser))
				__inputParsers[key] = path
			else
				__inputParsers[key] = new path()
			return __inputParsers[key]

		addFormatter(key, path)
			if(key in __inputFormatters) return 0
			if(istype(path, /inputFormatter))
				__inputFormatters[key] = path
			else
				__inputFormatters[key] = new path()
			return __inputFormatters[key]

		getParser(n)
			if(n in __inputParsers) return __inputParsers[n]
			else if(ispath(n))
				return new n()

		getFormatter(n)
			if(n in __inputFormatters) return __inputFormatters[n]
			else if(ispath(n))
				return new n()

	var
		list/__inputParsers = new()
		list/__inputFormatters = new()
		STATE_INIT  = 1
		STATE_READY = 2
		STATE_ACCEPT = 3
		STATE_DONE = 4
		STATE_ERROR = 5

		FORMAT_QUESTION = 1
		FORMAT_ERROR = 2

		INPUT_BAD = "AKLSJD&*^@#!*()_)JKSDAKLJS)(@*#($*(%*Y@()#)*(:"
		INPUT_NOT_READY = "AKLSDJLKASJD()@#$*)@(#*ASKLJDLK"

		ANSWER_TYPE_NUM = "num"
		ANSWER_TYPE_LIST = "list"
		ANSWER_TYPE_NUMLIST = "numlist"
		ANSWER_TYPE_YESNO = "yesno"
		ANSWER_TYPE_ANY = "any"
