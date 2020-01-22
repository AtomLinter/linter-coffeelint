// This file is a Task file that will run in a separate process
// https://atom.io/docs/api/v1.19.0/Task

const resolve = require('resolve');
const path = require('path');
const semver = require('semver');
const ignore = require('ignore');
const fs = require('fs');

const resolveCoffeeLint = (filePath) => {
  try {
    // check for coffeelint in project
    return path.dirname(resolve.sync('coffeelint/package.json', {
      basedir: path.dirname(filePath),
    }));
  } catch (ex) {
    if (!ex.message.startsWith("Cannot find module 'coffeelint/package.json'")) {
      throw ex;
    }
  }

  try {
    // check for @coffeelint/cli in project
    return path.dirname(resolve.sync('@coffeelint/cli/package.json', {
      basedir: path.dirname(filePath),
    }));
  } catch (ex) {
    if (!ex.message.startsWith("Cannot find module '@coffeelint/cli/package.json'")) {
      throw ex;
    }
  }

  return '@coffeelint/cli';
};

const configImportsModules = (config) => {
  if (!config) {
    return false;
  }
  return Object.keys(config).some(ruleName => (
    Object.prototype.hasOwnProperty.call(config[ruleName], 'module')
  ));
};

module.exports = (filePath, source, isLiterate, linterConfig) => {
  const fileDir = path.dirname(filePath);
  process.chdir(fileDir);

  // Adapted from how CoffeeLint itself does this
  // https://github.com/clutchski/coffeelint/blob/v1.16.1/src/commandline.coffee#L256
  if (fs.existsSync('.coffeelintignore')) {
    // Filter the current file path based on a .coffeelintignore file
    const filteredPath = ignore()
      .add(fs.readFileSync('.coffeelintignore').toString())
      .filter([filePath]);
    if (filteredPath.length === 0) {
      // Path was filtered out, return no results
      return [];
    }
  }

  let showUpgradeError = false;

  let coffeeLintPath = resolveCoffeeLint(filePath);
  // eslint-disable-next-line import/no-dynamic-require
  let coffeelint = require(coffeeLintPath);

  // Versions before 1.9.1 don't work with Atom because of an assumption that
  // if window is defined, then it must be running in a browser. Atom breaks
  // this assumption, so CoffeeLint < 1.9.1 will fail to find CoffeeScript.
  // See https://github.com/clutchski/coffeelint/pull/383
  if (semver.lt(coffeelint.VERSION, '1.9.1')) {
    coffeeLintPath = '@coffeelint/cli';
    // eslint-disable-next-line import/no-dynamic-require
    coffeelint = require(coffeeLintPath);
    showUpgradeError = true;
  }

  // eslint-disable-next-line import/no-dynamic-require
  let configFinder = require(`${coffeeLintPath}/lib/configfinder`);
  let config;
  try {
    config = configFinder.getConfig(filePath);
  } catch (ex) {
    // this version of coffeelint could not find a config file
    // fail silently
  }

  if (!showUpgradeError) {
    if (configImportsModules(config) && semver.lt(coffeelint.VERSION, '1.9.5')) {
      coffeeLintPath = '@coffeelint/cli';
      /* eslint-disable import/no-dynamic-require */
      coffeelint = require(coffeeLintPath);
      configFinder = require(`${coffeeLintPath}/lib/configfinder`);
      /* eslint-enable import/no-dynamic-require */
      config = configFinder.getConfig(filePath);
      showUpgradeError = true;
    }
  }

  if (!config) {
    if (linterConfig.disableIfNoConfig) {
      return [];
    }

    if (linterConfig.defaultConfig) {
      let configFile = linterConfig.defaultConfig;
      if (!configFile.endsWith('coffeelint.json')) {
        configFile = path.join(configFile, 'coffeelint.json');
      }
      config = configFinder.getConfig(configFile);
    }
  }

  try {
    const results = coffeelint.lint(source, config, isLiterate);

    if (showUpgradeError) {
      results.push({
        lineNumber: 1,
        level: 'error',
        message: "https://git.io/local_upgrade upgrade your project's CoffeeLint",
        rule: 'none',
      });
    }

    return results;
  } catch (ex) {
    return [{
      lineNumber: 1,
      level: 'error',
      message: ex.message,
      rule: 'CoffeeLint Error',
    }];
  }
};
