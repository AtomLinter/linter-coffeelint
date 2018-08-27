'use babel';

// eslint-disable-next-line import/no-extraneous-dependencies, import/extensions
import { Task } from 'atom';

// Dependencies
let atomLinter;
let workerFile;

const loadDeps = () => {
  if (!atomLinter) {
    atomLinter = require('atom-linter');
  }
  if (!workerFile) {
    workerFile = require.resolve('./worker.js');
  }
};

module.exports = {
  config: {
    defaultConfig: {
      title: 'coffeelint.json Path',
      description: "It will only be used when there's no config file in project",
      type: 'string',
      default: '',
    },
    disableIfNoConfig: {
      title: 'Disable when no coffeelint config is found (in package.json or coffeelint.json)',
      type: 'boolean',
      default: false,
    },
  },

  activate() {
    this.idleCallbacks = new Set();
    let depsCallbackID;
    const installLinterCoffeeLintDeps = () => {
      this.idleCallbacks.delete(depsCallbackID);
      if (!atom.inSpecMode()) {
        require('atom-package-deps').install('linter-coffeelint');
      }
      loadDeps();
    };
    depsCallbackID = window.requestIdleCallback(installLinterCoffeeLintDeps);
    this.idleCallbacks.add(depsCallbackID);

    this.workers = new Set();
  },

  deactivate() {
    this.workers.forEach((worker) => {
      if (worker != null) {
        worker.terminate();
      }
    });
    this.workers.clear();
    this.idleCallbacks.forEach(callbackID => window.cancelIdleCallback(callbackID));
    this.idleCallbacks.clear();
  },

  provideLinter() {
    return {
      name: 'CoffeeLint',
      grammarScopes: [
        'source.coffee',
        'source.litcoffee',
        'source.coffee.jsx',
        'source.coffee.angular',
      ],
      scope: 'file',
      lintsOnChange: true,
      lint: async (textEditor) => {
        const filePath = textEditor.getPath();
        if (!filePath) {
          return [];
        }
        const source = textEditor.getText();

        const isLiterate = textEditor.getCursors().some(cursor => (
          cursor.getScopeDescriptor().getScopesArray().some(scope => (
            scope === 'source.litcoffee'
          ))
        ));

        const linterConfig = atom.config.get('linter-coffeelint');

        const transform = ({
          level, message, rule, lineNumber, context,
        }) => {
          let excerpt = message;
          if (context) {
            excerpt = `${message}. ${context}`;
          }
          if (rule !== 'none') {
            excerpt = `${excerpt}. (${rule})`;
          }

          return {
            severity: level === 'error' ? 'error' : 'warning',
            excerpt,
            location: {
              file: filePath,
              position: atomLinter.generateRange(textEditor, lineNumber - 1),
            },
          };
        };

        loadDeps();

        return new Promise((resolve, reject) => {
          const task = Task.once(
            workerFile,
            filePath,
            source,
            isLiterate,
            linterConfig,
            (results) => {
              this.workers.delete(task);
              try {
                resolve(results.map(transform));
              } catch (e) {
                reject(e);
              }
            },
          );
          this.workers.add(task);
          task.on('task:error', e => reject(e));
        });
      },
    };
  },
};
