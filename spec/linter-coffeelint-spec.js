'use babel';

import { join } from 'path';
// eslint-disable-next-line no-unused-vars
import { it, fit, wait, beforeEach, afterEach } from 'jasmine-fix';

const fixturesPath = join(__dirname, 'fixtures');
const validPath = join(fixturesPath, 'valid', 'valid.coffee');
const validCoffeelintPath = join(fixturesPath, 'valid_coffeelint', 'valid.coffee');
const arrowSpacingPath = join(fixturesPath, 'arrow_spacing', 'arrow_spacing.coffee');
const arrowSpacingWarningPath = join(fixturesPath, 'arrow_spacing_warning', 'arrow_spacing.coffee');
const linter = require('../src').provideLinter();

describe('The CoffeeLint provider for Linter', () => {
  beforeEach(async () => {
    // Info about this beforeEach() implementation:
    // https://github.com/AtomLinter/Meta/issues/15
    const activationPromise = atom.packages.activatePackage('linter-coffeelint');

    await atom.packages.activatePackage('language-coffee-script');
    await atom.workspace.open(validPath);

    atom.packages.triggerDeferredActivationHooks();
    await activationPromise;
  });

  it('should be in the packages list', () =>
    expect(atom.packages.isPackageLoaded('linter-coffeelint')).toBe(true),
  );

  it('should be an active package', () =>
    expect(atom.packages.isPackageActive('linter-coffeelint')).toBe(true),
  );

  describe('works with CoffeeScript files and', () => {
    it('finds something wrong with an invalid file', async () => {
      const msgText = 'Function arrows (-> and =>) must be spaced properly. (arrow_spacing)';
      const editor = await atom.workspace.open(arrowSpacingPath);
      const messages = await linter.lint(editor);

      expect(messages.length).toBe(1);
      expect(messages[0].severity).toBe('error');
      expect(messages[0].excerpt).toBe(msgText);
      expect(messages[0].location.file).toBe(arrowSpacingPath);
      expect(messages[0].location.position).toEqual([[6, 0], [6, 12]]);
    });

    it('uses the config file from the project', async () => {
      const msgText = 'Function arrows (-> and =>) must be spaced properly. (arrow_spacing)';
      const editor = await atom.workspace.open(arrowSpacingWarningPath);
      const messages = await linter.lint(editor);

      expect(messages.length).toBe(1);
      expect(messages[0].severity).toBe('warning');
      expect(messages[0].excerpt).toBe(msgText);
      expect(messages[0].location.file).toBe(arrowSpacingWarningPath);
      expect(messages[0].location.position).toEqual([[6, 0], [6, 12]]);
    });

    it('finds nothing wrong with a valid file', async () => {
      const editor = await atom.workspace.open(validPath);
      const messages = await linter.lint(editor);

      expect(messages.length).toBe(0);
    });

    it('uses coffeelint from the project', async () => {
      const editor = await atom.workspace.open(validCoffeelintPath);
      const messages = await linter.lint(editor);

      expect(messages.length).toBe(1);
      expect(messages[0].severity).toBe('warning');
      expect(messages[0].excerpt).toBe('test message. (test rule)');
      expect(messages[0].location.file).toBe(validCoffeelintPath);
      expect(messages[0].location.position).toEqual([[0, 0], [0, 41]]);
    });
  });
});
