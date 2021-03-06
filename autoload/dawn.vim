" Dawn.vim
" License: MIT
" Maintainer: https://github.com/LunarWatcher
scriptencoding utf-8

let g:DawnVersion = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

fun! s:define(name, default)
    if !exists(a:name)
        let {a:name} = a:default
    endif
endfun

call s:define('g:DawnDefaultTemplates', ["vim"])
call s:define('g:DawnProjectTemplates', {})
call s:define('g:DawnSearchPaths', [])

if len(g:DawnDefaultTemplates) != 0 && index(g:DawnSearchPaths, expand('<sfile>:p:t') . 'templates/') < 0

endif

if index(g:DawnDefaultTemplates, 'vim') != -1
            \ && !has_key(g:DawnProjectTemplates, 'vim')
    let g:DawnProjectTemplates["vim"] = {
                \ "folders": [
                    \ "doc/", "autoload", "plugin"
                    \ ],
                \ "files": {
                    \ "doc/%dn.txt": {'content': function('dawn#vim#GenerateHelpDoc')},
                    \ "plugin/%dn.vim": {'content': ''},
                    \ "autoload/%dn.vim": {'content': ''},
                    \ ".gitignore": {"content": "doc/tags"},
                    \ "LICENSE": {"content": ""},
                    \ "README.md": {"content": ""},
                    \ "CHANGELOG.md": {"content": ""}
                \ }
            \ }
endif

fun! dawn#DeclareTemplates(templates)
    if type(a:templates) != v:t_dict
        echoerr "dawn#DeclareTemplates takes a dict"
        return
    endif

    for [name, template] in templates
        let g:DawnProjectTemplates[name] = template
    endfor
endfun

fun! dawn#GenerateProject(templateName)
    if !has_key(g:DawnProjectTemplates, a:templateName)
        echoerr "There's no template by the name of " . a:templateName
        return
    endif
    let template = g:DawnProjectTemplates[a:templateName]

    if !has_key(template, 'folders') && !has_key(template, 'files') && !has_key(template, 'commands') < 0
        echoerr "The template " . a:templateName . " is missing folders, files, and commands; at least one of them have to be present for the object to be valid"
        return
    endif

    " Iterate folders
    if has_key(template, 'folders')
        echo "Generating folders..."
        for folder in template["folders"]
            silent! call mkdir(folder, "p")
        endfor
        echo "Done."
    endif
endfun

let &cpoptions = s:save_cpo
unlet s:save_cpo
