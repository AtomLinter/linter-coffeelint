[![Stories in Ready](https://badge.waffle.io/AtomLinter/linter-coffeelint.png?label=ready&title=Ready)](https://waffle.io/AtomLinter/linter-coffeelint)
linter-coffeelint
=========================

This linter plugin for [Linter](https://github.com/AtomLinter/Linter) provides an interface to [coffeelint](http://www.coffeelint.org/). It will be used with files that have the “CoffeeScript” or “CoffeeScript (literate)” syntax.

## Installation
Linter package must be installed in order to use this plugin. If Linter is not installed, please follow the instructions [here](https://github.com/AtomLinter/Linter).

### Plugin installation
```
$ apm install linter-coffeelint
```

## Settings

As of v0.2.0 there is no need to specify a path to coffeelint. If you need to use a specific version you can specify it in your project's `package.json` and `linter-coffeelint` will use that one. This is the same behavior the coffeelint commandline gives you.

Your configuration belongs in your project, not your editor.
https://github.com/clutchski/coffeelint/blob/master/doc/user.md

## Contributing
If you would like to contribute enhancements or fixes, please do the following:

1. Fork the plugin repository.
1. Hack on a separate topic branch created from the latest `master`.
1. Commit and push the topic branch.
1. Make a pull request.
1. welcome to the club

Please note that modifications should follow these coding guidelines:

- Indent is 2 spaces.
- Code should pass coffeelint linter.
- Vertical whitespace helps readability, don’t be afraid to use it.

Thank you for helping out!

## Donation
[![Share the love!](https://chewbacco-stuff.s3.amazonaws.com/donate.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KXUYS4ARNHCN8)
