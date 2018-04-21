part of bonobo.src.commands;

class LanguageServerCommand extends Command {
  final String name = 'language_server';
  final String description = 'Runs a VSCode language server.';

  @override
  run() {
    var server = new BonoboLanguageServer();
    var stdio = new lsp.StdIOLanguageServer.start(server);
    return stdio.onDone;
  }
}
