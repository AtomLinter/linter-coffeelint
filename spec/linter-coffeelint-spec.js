'use babel';

import { join } from 'path';

const validPath = join(__dirname, 'fixtures', 'valid', 'valid.coffee');
const arrowSpacingPath = join(__dirname, 'fixtures', 'arrow_spacing', 'arrow_spacing.coffee');
const linter = require('../lib/init.coffee').provideLinter();

describe('The CoffeeLint provider for Linter', () => {
  describe('works with CoffeeScript files and', () => {
    beforeEach(() => {
      // Info about this beforeEach() implementation:
      // https://github.com/AtomLinter/Meta/issues/15
      const activationPromise =
        atom.packages.activatePackage('linter-coffeelint');

      waitsForPromise(() =>
        atom.packages.activatePackage('language-coffee-script').then(() =>
          atom.workspace.open(validPath)));

      atom.packages.triggerDeferredActivationHooks();
      waitsForPromise(() => activationPromise);
    });

    it('finds something wrong with an invalid file', () => {
      const msgText = 'Function arrows (-> and =>) must be spaced properly. (arrow_spacing)';
      waitsForPromise(() =>
        atom.workspace.open(arrowSpacingPath).then(editor => linter.lint(editor))
          .then((messages) => {
            expect(messages.length).toBe(1);
            expect(messages[0].severity).toBe('error');
            expect(messages[0].excerpt).toBe(msgText);
            expect(messages[0].location.file).toBe(arrowSpacingPath);
            expect(messages[0].location.position).toEqual([[6, 0], [6, 12]]);
          }),
      );
    });

    it('finds nothing wrong with a valid file', () =>
      waitsForPromise(() =>
        atom.workspace.open(validPath).then(editor => linter.lint(editor)).then((messages) => {
          expect(messages.length).toBe(0);
        }),
      ),
    );
  });
});
