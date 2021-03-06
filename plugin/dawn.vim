if exists('g:DawnLoaded')
    finish
endif
let g:DawnLoaded = 1

fun! DawnPromptProject(...)
    if a:0 == 0
        " TODO: prompt
    else
        call dawn#GenerateProject(a:1)
    endif

endfun

command! -nargs=? GenerateTemplate call DawnPromptProject(<f-args>)

