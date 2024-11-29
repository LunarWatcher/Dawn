if exists('g:DawnLoaded')
    finish
endif
let g:DawnLoaded = 1

fun! DawnPromptProject(...)
    call dawn#GenerateProject(a:1)
endfun

fun! s:SortByStridx(a, b, search)
    let aidx = a:a->stridx(a:search)
    let bidx = a:b->stridx(a:search)

    if (aidx == bidx)
        return 0
    elseif (aidx > bidx)
        return 1
    else
        return -1
    endif

endfun

fun! s:CompleteTemplates(ArgLead, _CmdLine, _CursorPos)
    let templates = dawn#ListTemplatesAsList()
    if (a:ArgLead == "")
        return templates
    endif
    let output = []
    for template in templates
        if (template->stridx(a:ArgLead->tolower()) != -1)
            call add(output, template)
        endif
    endfor
    return output
endfun

command! -nargs=+ -complete=customlist,s:CompleteTemplates DawnGenerate call DawnPromptProject(<f-args>)
command! -nargs=0 DawnList call dawn#ListTemplates()

nnoremap <C-g><C-l> :DawnList<CR>
