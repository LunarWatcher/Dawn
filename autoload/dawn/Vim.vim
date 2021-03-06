" That file name though. Y i k e s

fun! dawn#vim#GenerateHelpDoc()
    return "*%ldn* *%ldn.vim* *%ldn.txt*\n"
                \ . "\nLicense: Your license here\nURL: Your URL here\n"
                \ . "\nChangelog:\n\n" . repeat('=', 80) . "\n"
                \ . "Table of contents~\n\n    1. Table of contents base\n\n"
                \ . repeat('=', 80) . "\n\n\nvim:ft=help:tw=80"
endfun

