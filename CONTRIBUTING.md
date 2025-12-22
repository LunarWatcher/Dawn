# Contribution guidelines

This file is mostly aimed at developers, and primarily describes the setup required for development, and project-specific things to think about when contributing code. For general open-source contribution guidelines, see [opensource.guide](//opensource.guide). The guidelines listed under "Basic guidelines" do apply to all forms of contributions, including issues.

This file will not go into detail on how to write issues. Any important details that need to be included (if any) will be part of an issue template, selectable when you create an issue. If none exists for your use-case (or at all), use common sense. I do strongly suggest reading [the section on communicating effectively on opensource.guide](https://opensource.guide/how-to-contribute/#communicating-effectively) if you're wondering how to write good issues. There's nothing anyone could write here that isn't covered there and in thousands of other resources around the internet in far greater detail.

## Basic guidelines

### Use of generative AI is banned

Generative AI uses training data [based on plagiarism and piracy](https://web.archive.org/web/20250000000000*/https://www.theatlantic.com/technology/archive/2025/03/libgen-meta-openai/682093/), has [significant environmental costs associated with it](https://doi.org/10.21428/e4baedd9.9070dfe7), and [generates fundamentally insecure code](https://doi.org/10.1007/s10664-024-10590-1). GenAI is not ethically built, ethical to use, nor safe to use for programming applications. When caught, you will be permanently banned from contributing to the project, and any prior contributions will be checked and potentially reverted. Any and all contributions you've made cannot be trusted if AI slop machines were involved.

## Development setup

### Running tests

The tests require [themis](https://github.com/thinca/vim-themis) to run. Install it as a plugin in vim using your favourite plugin manager, add its `bin` to your PATH, then run `themis` from the root directory.

### Testing policy

As much of the code should be tested as possible, within reason.

The primary goal of tests is to ensure there's a support framework that prevents backsliding in code quality. With enough tests, you don't need to worry as much about breaking something unrelated to what you were working on. 100% coverage is a pointless metric, but coverage tools can be useful to tell what critical paths aren't being tested. In real code, many paths may legitimately be unreachable without doing an awful lot of fucking around, particularly in exception handlers. Doing elaborate bullshit to test every possible path in the code, including trivial paths, is a waste of time and effort.

In practice, this means:

* If you're writing new functionality, write tests for the core parts of it
* If you're fixing a bug that was reported, write regression tests
* If you're working with edge-cases, test them

Writing tests isn't always feasible, but it should be attempted whereever possible. However, if any tests break, they must be fixed. Removal should only be done if the corresponding functionality is removed, and not as a way to bypass the test failures to maybe perhaps fix later.

Note that the templates themselves are not currently validated. There is a test to make sure _a_ template is properly generated, but there's no point in doing this generally. Templates using obscure features SHOULD be tested, but this is a feature test and not a test of that template.

## Adding [to] templates

The templates are kept in the `templates` directory. For information about the templates, see the entire section starting at `:h dawn-template-structure`.

Due to limitations of Vim's `glob()` function, template files cannot start with a `.`. If your template needs to include such files, notably including CI workflows, give it a name that doesn't start with a `.`, and then link it in the manifest. For example, given `.github/workflows/whatever.yaml`, extend `dawn-manifest.json` to include:
```json
{
    "link": {
        "github": ".github"
    }
}
```

This relinks the entire folder. See also `:h dawn-manifest.json` and `:h dawn-template-limitations`.

### What should a template contain?

Templates should generally only contain the bare minimum required to build a project of a given type. Templates can further be split into two types: 

1. Project templates
2. Support templates

These are addressed separately.

However, in common for both types of templates is that certain opinions have to be taken. It is not feasible to include every conceivable variation in the first-party template repo, so they have to be somewhat opinionated. The opinions imposed should be minimal, easy to remove, and more importantly, very common. For example, the CMake template includes a specific project structure where headers and includes are kept together. This is one of the two most common structures, and it can be altered by creating another folder, and adding a new CMake statement. It's just a couple manual actions away from the other most common structure. 

CMake is used for the build. It's not the only option, but it is the most common option. It also assumes the build isn't done inline, and is instead done in a separate folder. This is a very common practice, with many projects outright blocking in-source builds.

#### Project templates

Project templates are full templates. These are typically for programming languages or frameworks, i.e. the core of a project.

The project templates need to contain everything required for a "Hello, World" project, and where applicable, a scaffold for a unit test setup. The template should also be able to build and run the template.

As few libraries as possible should be added during this process. Unless it's necessary or represents a common sense standard, it should not be included. Libraries are just as subjective as any other standard, and is another breeding ground for pointless flamewars.

In addition to everything required to get the project up and running, it must include other project scaffolding, including a template README, an empty LICENSE file, and if applicable, a gitignore. License files and other empty files are set up in `dawn-manifest.json`:
```json
{
    "create.files": [
        "LICENSE"
    ]
}
```

If the template has a build step that includes entering a folder, that also goes in the manifest. This also applies to structural folders that are optional, such as a `docs` folder:
```json
    "create.folders": [
        "build",
        "docs"
    ]
```

If your template includes a build step, add that to the `after` array. You can also include an `edit` command here if it makes sense to jump the user straight into a specific file. Do not include full layouts here, and err on the side not opening files.

```json
    "after": [
        "!cd build && cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && make -j $(nproc) && make run",
        "edit src/**/Main.cpp"
    ]
```

##### What goes in a README?

Preferably, nothing. If something has to go in it because it requires steps that aren't standard, write the bare minimum, and let the generating user write their own instructions.

There are exceptions to this, but this is on a per-case basis. Use your best judgement, and that's good enough.

#### Support templates

Support templates are for features that primarily go inside an existing project. Mkdocs is a good example of this; while it can be standalone, in a _lot_ of cases, it goes inside another repo. Consequently, support templates do not need the same repository infrastructure a project template does; this means no license files need to be generated, no READMEs, etc. 

Support templates SHOULD include a support README. mkdocs has `mkdocs-README.md`, which contains meta instructions for how to use the template. The file also explicitly includes instructions to delete the file, and include the instructions somewhere else, since the README isn't written for the end-users of the project. Note that this isn't meant to be enforced in any way, the support template READMEs are just primarily inteded to be used by the person generating it to provide proper instructions at whatever technical level they feel is appropriate.

Otherwise, the support templates contain the same thing as project templates; the bare minimum needed to get the support template running, if it is runnable. Since support templates are support templates and not project templates, it's assumed another template has or will provide the project scaffold files.


### What about ...?

This project simplifies entire project structures into one single folder. There's way more that could be written about it than what's written here. 

If you're in doubt, you can either ask or just try. I wrote this for my own use, and it (as expected, mind you) hasn't gained enough traction for me to get enough input to address other use-cases, so we'd be making up things as we go anyway.

If you have different needs than a middleground standard, you can also create your own template repository. The idea here is that end-users can add whatever template repositories they want to their `.vimrc`s, including priority, and dawn will search those in order. At this time, the feature allowing this is not in place and not on my immediate roadmap, but if you need it soon:tm:, open an issue and let me know, and I'll prioritise it. Going straight for a PR would also be appreciated :)
