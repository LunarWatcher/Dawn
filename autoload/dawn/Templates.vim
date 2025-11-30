vim9script

export def InitTemplates()
    if index(g:DawnDefaultTemplates, 'vim') != -1
            && !has_key(g:DawnProjectTemplates, 'vim')
        g:DawnProjectTemplates["vim"] = {
            "folders": [
                "doc/", "autoload", "plugin"
            ],
            "files": {
                "doc/%{ldn}.txt": {'content': function('dawn#Vim#GenerateHelpDoc')},
                "plugin/%{ldn}.vim": {},
                "autoload/%{ldn}.vim": {},
                ".gitignore": {"content": "doc/tags"},
                "LICENSE": {},
                "README.md": {},
                "CHANGELOG.md": {}
            }
        }
    endif
    if index(g:DawnDefaultTemplates, 'cpp') != -1
            && !has_key(g:DawnProjectTemplates, 'cpp')
        g:DawnProjectTemplates["cpp"] = {
            "folders": [ "src", "build", "src/%{ldn}", "docs", "tests", "tests/src" ],
            "files": {
                "CMakeLists.txt": { 'source': 'cpp/CMakeLists.root.txt' },
                "src/CMakeLists.txt": { 'source': 'cpp/CMakeLists.src.txt' },
                "src/%{ldn}/Main.cpp": { 'content': "#include <iostream>\n\nint main() {\n    std::cout << \"Hello, World!\" << std::endl;\n}" },
                "tests/CMakeLists.txt": { 'source': 'cpp/CMakeLists.test.txt' },
                "LICENSE": {},
                "README.md": { 'content': "# %{dn}\n" },
                ".gitignore": { 'source': 'cpp/cpp.gitignore' }
            },
            "commands": [ "!cd build && cmake .. -DCMAKE_BUILD_TYPE=Debug && make && ./bin/%{ldn}" ]
        }
    endif
    if index(g:DawnDefaultTemplates, 'go') != -1
            && !has_key(g:DawnProjectTemplates, 'go')
        g:DawnProjectTemplates["go"] = {
            "folders": [ "cmd", "pkg" ],
            "files": {
                "main.go": { 'content': "package main\n\nimport \"fmt\"\n\nfunc main() {\n\tfmt.Println (\"Hello, World!\")\n}" },
                "LICENSE": {},
                "README.md": { 'content': "# %{dn}\n" },
                ".gitignore": { 'source': 'go/go.gitignore' }
            },
            "commands": [ 'silent! !git init && git add . && git commit -m "Initial commit"', 'edit +/Hello main.go' ]
        }
    endif

enddef
