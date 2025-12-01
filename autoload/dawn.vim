vim9script

import autoload "dawn/ParseContext.vim" as ctx
import autoload "dawn/Variables.vim"
import autoload "dawn/Utils.vim" as utils
Variables.Load()

add(g:DawnSearchPaths, expand("<sfile>:p:h:h") .. "/templates")

export def DoSubstitute(
    context: ctx.ParseContext,
    full: string,
    name: string,
    operator: string
): string
    var repl = context.GetTemplateArg(name)
    if (repl == null)
        return full
    endif

    if (operator == ".lower")
        repl = repl->tolower()
    elseif (len(operator) > 0)
        echoerr "Dawn arg evaluation error: Unknown operator" operator
    endif

    return repl
enddef

# Note: even though this is an export, this is purely for use in tests. This
# is an internal API that can break at any time. Do not use externally
export def InternalSubstitute(
    str: any,
    type: number,
    context: ctx.ParseContext = ctx.ParseContext.new({}),
): any
    if type(str) == v:t_list
        var result = []
        for line in str
            add(result, InternalSubstitute(line, type))
        endfor
        return result
    endif
    var result = str

    result = substitute(
        result,
        '\v\%\{(\w+)(\.\w+)?\}',
        '\=dawn#DoSubstitute(context, submatch(0), submatch(1), submatch(2))',
        'g'
    )

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

export def CheckLink(
    context: ctx.ParseContext,
    config: dict<any>,
    relpath: string
): string
    var links = config->get("link", {})
    if links->has_key(relpath)
        return InternalSubstitute(
            links->get(relpath, relpath),
            0, # TODO: Remove type arg
            context
        )
    endif
    for [key, target] in links->items()
        if relpath->stridx(key) == 0
            var substr = relpath[len(key) : ]
            var dest = target .. "/" .. substr
            return InternalSubstitute(
                dest,
                0, # TODO: Remove type arg
                context
            )
        endif
    endfor

    return relpath
enddef

export def RunCreate(conf: dict<any>)
    var files = conf->get("create.files", [])
    for file in files
        writefile([], file)
        echo "Create empty file:" file
    endfor

    var folders = conf->get("create.folders", [])
    for folder in folders
        mkdir(folder, "p")
        echo "Create empty folder:" folder
    endfor
enddef

export def GenerateProject(templateName: string, skipAfter: bool = false)
    # Locate the template
    # TODO: this does not respect g:DawnSearchPaths->len() > 0
    var templateSearchPath = g:DawnSearchPaths[0]
    var templatePath = templateSearchPath .. "/" .. templateName
    if !templatePath->isdirectory()
        echoerr "Failed to find template directory for " templatePath
    endif

    # Locate the manifest. If no manifest, treat it as being equal to an empty
    # manifest. Not all templates need a manifest
    var conf: dict<any> = {}
    var confPath = templatePath .. "/dawn-manifest.json"
    if filereadable(confPath)
        conf = json_decode(readfile(confPath)->join("\n"))
    endif

    var context = ctx.ParseContext.new(
        conf->get("arguments", {})->get("custom", {})
    )

    RunCreate(conf)

    var paths = globpath(templatePath, "**/*", 0, 1)
    for path in paths
        var rel = utils.ToRelative(path, templatePath)
        var fn = fnamemodify(path, ":t")
        # Where the file gets copied to
        var dest = CheckLink(
            context,
            conf,
            rel
        )
        if isdirectory(path)
            mkdir(dest, "p")
            continue
        endif
        if fn == "dawn-manifest.json"
            # dawn-manifest.json should not be copied
            continue
        elseif fn == "template.gitignore"
            dest = dest->substitute("template.gitignore", ".gitignore", "")
        endif

        var contents = readfile(path)
        var parsedContents = []
        for line in contents
            parsedContents->add(
                InternalSubstitute(
                    line,
                    0,
                    context
                )
            )
        endfor
        writefile(
            parsedContents,
            dest
        )
        echo "Create from template:" dest 
    endfor

    if !skipAfter
        var after: list<string> = conf->get("after", [])
        for command in after
            if command->trim()->len() > 0
                exec command
            endif
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
    var templateDir = g:DawnSearchPaths[0]
    var out: list<string> = []
    for path in glob(templateDir .. "/*", 0, 1)
        out->add(
            fnamemodify(path, ":t")
        )
    endfor
    return out
enddef
