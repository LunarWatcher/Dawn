# Changelog

## [Unreleased]

### Changed

* Switched to vim9script
* Refactored the entire template system to be directory/metadata-file-based. This makes it substantially easier to scale the templates, as no templates are involved
* Arguments (`%{...}`)
    * `dn` and `ldn` are now `name`. 
    * Lower-case variants of an argument can now be done with the `.lower` operator (`%{name.lower}`). This applies to all arguments. See the added section for operators in general
    * Templates can add custom arguments, though the defaults for them are just strings. Not sure what use this has standalone without a script around it, but we'll see.

### Added

* Added operator syntax for arguments (`%{name.operator}`)
    * `.lower` is the only currently supported operator. Not sure what else makes sense to add, especially since operators currently to not support arguments.
* Added some tests with themis

### Fixed

* Cleaned up several bits of _very_ legacy behaviour.

### Removed

* Removed `g:DawnVersion`, because the pattern honestly makes no sense

## v0.1.0

Initial release

[Unreleased]: https://github.com/LunarWatcher/Dawn/compare/v0.1.0...master
