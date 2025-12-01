vim9script

export def Load()
    if !exists("g:DawnSearchPaths")
        g:DawnSearchPaths = []
    endif
    if !exists("g:DawnSkipExisting")
        g:DawnSkipExisting = 1
    endif

enddef
