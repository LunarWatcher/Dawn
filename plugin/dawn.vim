vim9script

import autoload 'dawn.vim' as dawn

def DawnPromptProject(templateName: string)
    call dawn.GenerateProject(templateName)
enddef

def SortByStridx(a: string, b: string, search: string)
    var aidx = a->stridx(search)
    var bidx = b->stridx(search)

    if (aidx == bidx)
        return 0
    elseif (aidx > bidx)
        return 1
    else
        return -1
    endif

enddef

def CompleteTemplates(ArgLead: any, CmdLine: any, _CursorPos: any): list<string>
    if CmdLine->trim()->stridx(" ") == -1
        # Option 1: no space means first argument
        var templates = dawn.ListTemplatesAsList()
        if (ArgLead == "")
            return templates
        endif
        var output = []
        for template in templates
            if (template->stridx(ArgLead->tolower()) != -1)
                add(output, template)
            endif
        endfor
        return output
    else
        # Nth argument, currently not in use
        return []
    endif
enddef

command! -nargs=1 -complete=customlist,CompleteTemplates DawnGenerate DawnPromptProject(<f-args>)
command! -nargs=0 DawnList call dawn.ListTemplates()

nnoremap <C-g><C-l> :DawnList<CR>
