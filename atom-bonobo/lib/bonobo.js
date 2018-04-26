const cp = require('child_process');
const {AutoLanguageClient} = require('atom-languageclient')

class BonoboLanguageClient extends AutoLanguageClient {
   getGrammarScopes() {
     return ['source.bonobo', 'source.bnb'];
   }

   getLanguageName() {
     return 'Bonobo';
   }

   getServerName() {
     return 'Bonobo';
   }

   startServerProcess(projectPath) {
    const command = 'bonobo';
    const args = ['language_server'];
    const childProcess = cp.spawn(command, args);

    childProcess.on("error", err =>
      atom.notifications.addError("Unable to start the Bonobo language server.", {
        dismissable: true,
        buttons: [
          {
            text: "Install Instructions",
            onDidClick: () => atom.workspace.open("atom://config/packages/ide-bonobo")
          }
        ],
        description:
          "Please make sure you've followed the System Requirements section in the README"
      })
    );

    super.captureServerErrors(childProcess, projectPath);
    return childProcess;
  }
}

module.exports = new BonoboLanguageClient();
