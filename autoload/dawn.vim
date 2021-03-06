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
call s:define('g:DawnSkipExisting', 1)

if len(g:DawnDefaultTemplates) != 0 && index(g:DawnSearchPaths, expand('<sfile>:p:h') . '/templates') < 0
    call add(g:DawnSearchPaths, expand("<sfile>:p:h:h") . "/templates")
endif

if index(g:DawnDefaultTemplates, 'vim') != -1
            \ && !has_key(g:DawnProjectTemplates, 'vim')
    let g:DawnProjectTemplates["vim"] = {
                \ "folders": [
                    \ "doc/", "autoload", "plugin"
                    \ ],
                \ "files": {
                    \ "doc/%dn.txt": {'content': function('dawn#Vim#GenerateHelpDoc')},
                    \ "plugin/%dn.vim": {},
                    \ "autoload/%dn.vim": {},
                    \ ".gitignore": {"content": "doc/tags"},
                    \ "LICENSE": {},
                    \ "README.md": {},
                    \ "CHANGELOG.md": {},
                    \ "Bullshit": {"source": "README.md"}
                \ }
            \ }
endif

fun! dawn#InternalSubstitute(string, type)
    if type(a:string) == v:t_list
        let result = []
        for line in a:string
            call add(result, dawn#InternalSubstitute(line, a:type))
        endfor
        return result
    endif
    let result = a:string

    " Type:
    " 0 = ignore variables
    " 1 = file content
    " 2 = file name
    " 3 = command
    " 4 = folder name
    " TODO: use the type to determine whether or not to substitute
    let cwd = fnamemodify(getcwd(), ':t')

    let result = substitute(result, "%dn", cwd, "gi")
    let result = substitute(result, "%ldn", tolower(cwd), "gi")
    " More substitutions go above this comment

    return result
endfun

fun! dawn#DeclareTemplates(templates)
    if type(a:templates) != v:t_dict
        echoerr "dawn#DeclareTemplates takes a dict"
        return
    endif

    for [name, template] in templates
        let g:DawnProjectTemplates[name] = template
    endfor
endfun

fun! dawn#DawnCopy(source, target, abspath)
    if !a:abspath
        for directory in g:DawnSearchPaths
            if filereadable(directory . "/" . a:source)
                echo "Copying " . a:source . " to " . a:target
                let content = dawn#InternalSubstitute(readfile(directory . "/" . a:source), 1)
                call writefile(content, a:target)
                return
            endif
        endfor
        echoerr "Failed to find " . a:source . " in the search path."
    else
        echo "Copying " . a:source . " to " . a:target
        let content = dawn#InternalSubstitute(readfile(a:source), 1)
        call writefile(content, a:target)
    endif
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
            if g:DawnSkipExisting && isdirectory(folder)
                continue
            endif
            silent! call mkdir(dawn#InternalSubstitute(folder, 4), "p")
        endfor
        echo "Done."
    endif

    " After folders, initialize files
    if has_key(template, 'files')
        echo "Generating files..."
        for [file, data] in items(template["files"])
            let substFile = dawn#InternalSubstitute(file, 2)
            echo "Generating " . substFile
            if g:DawnSkipExisting && filereadable(substFile)
                continue
            endif

            if has_key(data, "content")
                if type(data["content"]) == v:t_func
                    call writefile(split(dawn#InternalSubstitute(data["content"](), 1), "\n"), substFile)
                else
                    call writefile(split(dawn#InternalSubstitute(data["content"], 1), "\n"), substFile)
                endif
            elseif has_key(data, "source")
                let path = data["source"]
                " We let DawnCopy handle checks on relative files and shit
                call dawn#DawnCopy(path, substFile, match(path, "^\v(.:[\\/]|/)") >= 0)
            else
                call writefile([], substFile)
            endif
        endfor
        echo "File generation done."
    endif

    if has_key(template, 'commands')
        for command in template["commands"]
            exec command
        endfor
    endif
endfun

let &cpoptions = s:save_cpo
unlet s:save_cpo
