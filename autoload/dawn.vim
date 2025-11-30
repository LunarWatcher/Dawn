vim9script

import autoload "dawn/Variables.vim"
Variables.Load()

import autoload "dawn/Templates.vim" as m_templates
m_templates.InitTemplates()

if len(g:DawnDefaultTemplates) != 0 && index(g:DawnSearchPaths, expand('<sfile>:p:h') .. '/templates') < 0
    add(g:DawnSearchPaths, expand("<sfile>:p:h:h") .. "/templates")
endif

def InternalSubstitute(str: any, type: number): any
    if type(str) == v:t_list
        var result = []
        for line in str
            add(result, InternalSubstitute(line, type))
        endfor
        return result
    endif
    var result = str

    # Type:
    # 0 = ignore variables
    # 1 = file content
    # 2 = file name
    # 3 = command
    # 4 = folder name
    # TODO: use the type to determine whether or not to substitute
    var cwd = fnamemodify(getcwd(), ':t')

    result = substitute(result, "%{dn}", cwd, "gi")
    result = substitute(result, "%{ldn}", tolower(cwd), "gi")
    # More substitutions go above this comment

    return result
enddef

export def DeclareTemplates(templates: dict<any>)
    for [name, template] in templates
        g:DawnProjectTemplates[name] = template
    endfor
enddef

export def DawnCopy(source: string, target: string, isAbsPath: bool)
    if !isAbsPath
        for directory in g:DawnSearchPaths
            if filereadable(directory .. "/" .. source)
                echom "Copying " .. source .. " to " .. target
                var content = InternalSubstitute(readfile(directory .. "/" .. source), 1)
                writefile(content, target)
                return
            endif
        endfor
        echoerr "Failed to find " .. source .. " in the search path."
    else
        echom "Copying " .. source .. " to " .. target
        var content = InternalSubstitute(readfile(source), 1)
        writefile(content, target)
    endif
enddef

export def GenerateProject(templateName: string)
    if !has_key(g:DawnProjectTemplates, templateName)
        echoerr "There's no template named " .. templateName
        return
    endif
    var template = g:DawnProjectTemplates[templateName]

    if !has_key(template, 'folders') && !has_key(template, 'files') && !has_key(template, 'commands')
        echoerr "The template " .. templateName .. " is missing folders, files, and commands; at least one of them have to be present for the object to be valid"
        return
    endif

    # Iterate folders
    if has_key(template, 'folders')
        echom "Generating folders..."
        for folder in template["folders"]
            if g:DawnSkipExisting && isdirectory(folder)
                continue
            endif
            silent! call mkdir(InternalSubstitute(folder, 4), "p")
        endfor
        echom "Done."
    endif

    # After folders, initialize files
    if has_key(template, 'files')
        echom "Generating files..."
        for [file, data] in items(template["files"])
            var substFile = InternalSubstitute(file, 2)
            echom "Generating " .. substFile
            if g:DawnSkipExisting && filereadable(substFile)
                continue
            endif

            if has_key(data, "content")
                if type(data["content"]) == v:t_func
                    writefile(split(InternalSubstitute(data["content"](), 1), "\n"), substFile)
                else
                    writefile(split(InternalSubstitute(data["content"], 1), "\n"), substFile)
                endif
            elseif has_key(data, "source")
                var path = data["source"]
                # We let DawnCopy handle checks on relative files and shit
                DawnCopy(path, substFile, match(path, "^\v(.:[\\/]|/)") >= 0)
            else
                writefile([], substFile)
            endif
        endfor
        echom "File generation done."
    endif

    if has_key(template, 'commands')
        for command in template["commands"]
            exec InternalSubstitute(command, 3)
        endfor
    endif
enddef

export def ListTemplates()
    echom "Valid template names: "
    for template in ListTemplatesAsList()
        echom '* ' .. template
    endfor
enddef

export def ListTemplatesAsList(): list<string>
    return keys(g:DawnProjectTemplates)
enddef
