vim9script

export def ToRelative(path: string, root: string): string
    # local root (I don't remember if I can modify the input args and I don't
    # feel like checking)
    var lr = root
    var relPath = path

    if lr[-1] != "/"
        lr ..= "/"
    endif

    # TODO: This almost certainly has escaping issues since it's treated as
    # regex
    relPath = relPath->substitute(
        "^" .. escape(lr, '\'),
        "",
        ""
    )
    return relPath
enddef
