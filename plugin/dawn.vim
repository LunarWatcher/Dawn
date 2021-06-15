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

command! -nargs=? DawnGenerate call DawnPromptProject(<f-args>)
command! -nargs=0 DawnList call dawn#ListTemplates()

nnoremap <C-g><C-l> :DawnList<CR>
