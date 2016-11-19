'use babel';

import { join } from 'path';

const validPath = join(__dirname, 'fixtures', 'valid', 'valid.coffee');
const arrowSpacingPath = join(__dirname, 'fixtures', 'arrow_spacing', 'arrow_spacing.coffee');
const lint = require('../lib/init.coffee').provideLinter().lint;

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

    it('finds nothing wrong with a valid file', () => {
      const msgText = 'Function arrows (-> and =>) must be spaced properly. (arrow_spacing)';
      waitsForPromise(() =>
        atom.workspace.open(arrowSpacingPath).then(editor => lint(editor)).then((messages) => {
          expect(messages.length).toBe(1);
          expect(messages[0].type).toBe('Error');
          expect(messages[0].html).not.toBeDefined();
          expect(messages[0].text).toBe(msgText);
          expect(messages[0].filePath).toBe(arrowSpacingPath);
          expect(messages[0].range).toEqual([[6, 0], [6, 12]]);
        })
      );
    });

    it('finds nothing wrong with a valid file', () =>
      waitsForPromise(() =>
        atom.workspace.open(validPath).then(editor => lint(editor)).then((messages) => {
          expect(messages.length).toBe(0);
        })
      )
    );
  });
});
