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
You can configure linter-coffeelint by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):
```
'linter-coffeelint':
  'coffeelintExecutablePath': null #coffeelint path. run 'which coffeelint' to find the path to the directory that holds the executable
```

**Note**: This plugin finds the nearest coffeelint.json file and uses the `-f` command line argument to use that file, so you may not use the `-f` argument in the linter settings.

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
