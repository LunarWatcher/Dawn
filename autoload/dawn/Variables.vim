vim9script

export def Load()
    if !exists('g:DawnDefaultTemplates') 
        g:DawnDefaultTemplates = ["vim", "cpp", "go"]
    endif
    if !exists("g:DawnProjectTemplates")
        g:DawnProjectTemplates = {}
    endif
    if !exists("g:DawnSearchPaths")
        g:DawnSearchPaths = []
    endif
    if !exists("g:DawnSkipExisting")
        g:DawnSkipExisting = 1
    endif

enddef
