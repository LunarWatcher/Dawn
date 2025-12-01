vim9script

export class ParseContext
    var builtinArgs: dict<string>
    var templateArgs: dict<string>

    def new(templateArgs: dict<string> = {})
        this.builtinArgs = {
            "name": getcwd()->fnamemodify(":t")
        }
        this.templateArgs = templateArgs
    enddef

    # Real return type: string | null
    def GetTemplateArg(key: string): any
        if has_key(this.builtinArgs, key)
            return this.builtinArgs[key]
        elseif has_key(this.templateArgs, key)
            return this.templateArgs[key]
        else
            return null
        endif
    enddef

endclass
