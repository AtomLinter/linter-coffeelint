<!-- [![Stories in Ready](https://badge.waffle.io/AtomLinter/linter-coffeelint.png?label=ready&title=Ready)](https://waffle.io/AtomLinter/linter-coffeelint) -->

[![Travis CI](https://travis-ci.org/AtomLinter/linter-coffeelint.svg?branch=master)](https://travis-ci.org/AtomLinter/linter-coffeelint)
[![Appveyor](https://ci.appveyor.com/api/projects/status/hcq63kmaskumyea5?svg=true)](https://ci.appveyor.com/project/UziTech/linter-coffeelint)
[![CircleCI](https://circleci.com/gh/AtomLinter/linter-coffeelint.svg?style=svg)](https://circleci.com/gh/AtomLinter/linter-coffeelint)
[![Dependencies](https://david-dm.org/AtomLinter/linter-coffeelint/status.svg)](https://david-dm.org/AtomLinter/linter-coffeelint)

#linter-coffeelint

This linter plugin for [Linter](https://github.com/AtomLinter/Linter) provides an interface to
[coffeelint](http://www.coffeelint.org/). It will be used with files that have the “CoffeeScript”
or “CoffeeScript (literate)” syntax.

## Installation
[Linter](https://github.com/AtomLinter/Linter) or [Atom IDE UI](https://ide.atom.io/) must be
installed to use this plugin. To install Linter please follow the instructions
[here](https://github.com/AtomLinter/Linter).


### Plugin Installation

```sh
$ apm install linter-coffeelint
```

## Settings

As of v0.2.0 there is no need to specify a path to coffeelint. If you need to use a specific
version you can specify it in your project's `package.json` and `linter-coffeelint` will use that
one. This is the same behavior the coffeelint commandline gives you.

[How do I configure CoffeeLint?](https://github.com/clutchski/coffeelint/blob/master/doc/user.md)

## Contributing

If you would like to contribute enhancements or fixes, please do the following:

1.  Fork the plugin repository.
1.  Hack on a separate topic branch created from the latest `master`.
1.  Commit and push the topic branch.
1.  Make a pull request.
1.  Welcome to the club 🎊

Please note that modifications must follow the ESLint configuration.

To check if the code complies, you may run:

```sh
$ npm run lint
```

-   Indent is 2 spaces.
-   Vertical whitespace helps readability, don’t be afraid to use it.

Thank you for helping out!
