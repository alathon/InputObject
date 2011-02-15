proc/Short2Full(short, full, ignorecase = 1)
	if(!short) return 0

	if(ignorecase)
		return (cmptext(short, copytext(full, 1, length(short)+1)))
	else
		return (cmptextEx(short, copytext(full, 1, length(short)+1)))