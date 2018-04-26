/* --------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for license information.
 * ------------------------------------------------------------------------------------------ */
'use strict';

const exec = require('child_process').exec;
const path = require('path');
const vscode = require('vscode');
const vscodeLanguageClient = require('vscode-languageclient');
const workspace = vscode.workspace, ExtensionContext = vscode.ExtensionContext;
const LanguageClient = vscodeLanguageClient.LanguageClient,
  LanguageClientOptions = vscodeLanguageClient.LanguageClientOptions,
  ServerOptions = vscodeLanguageClient.ServerOptions,
  TransportKind = vscodeLanguageClient.TransportKind;

exports.activate = function activate(context) {

  // The server is implemented in node
  const pubCommand = 'bonobo';
  const bonoboArgs = 'language_server'];

  const runOpts = { command: pubCommand, args: bonoboArgs, transport: TransportKind.stdio };

  // If the extension is launched in debug mode then the debug server options are used
  // Otherwise the run options are used
  const serverOptions = {
    run: runOpts,
    debug: runOpts
  };

  // Options to control the language client
  const clientOptions = {
    // Register the server for Bonobo documents
    documentSelector: [{ scheme: 'file', language: 'bonobo' }],
    synchronize: {
      // Synchronize the setting section 'languageServerExample' to the server
      configurationSection: 'bonobo',
      // Notify the server about file changes to '.bnb files contain in the workspace
      fileEvents: workspace.createFileSystemWatcher('**/.bnb')
    }
  };

  // Create the language client and start the client.
  const disposable = new LanguageClient('bonobo', 'Bonobo', serverOptions, clientOptions).start();

  // Push the disposable to the context's subscriptions so that the
  // client can be deactivated on extension deactivation
  context.subscriptions.push(disposable);

  // Set up the formatter.
  vscode.languages.registerDocumentFormattingEditProvider('bonobo', {
    provideDocumentFormattingEdits(document) {
      return new Promise((resolve, reject) => {
        /*
        const formatterOpts = JSON.stringify({
          file: document.fileName,
          lineLength: config.for(document.uri).lineLength,
          selectionLength: 0,
          selectionOffset: 0,
        });*/

        const command = `${pubCommand} global run bonobo format ${document.fileName} --lsp`;
        exec(command, (err, stdout, stderr) => {
          if (err) return reject(err);
          if (stderr.length)
            return reject(new Error(`Bonobo formatter failed: ${stderr}`));

          const resp = JSON.parse(stdout);
          resolve(resp);
        });
      });
    }
  });
};