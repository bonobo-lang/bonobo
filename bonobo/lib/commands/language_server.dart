part of bonobo.src.commands;

class LanguageServerCommand extends Command {
  final String name = 'language_server';
  final String description = 'Runs a VSCode language server.';
  final Logger logger = new Logger('bonobo.language_server');

  LanguageServerCommand() {
    hierarchicalLoggingEnabled = true;
    logger
      ..level = Level.FINEST
      ..onRecord.listen((rec) {
        stderr.writeln(rec);
        if (rec.error != null && rec.error is! UnimplementedError) {
          stderr.writeln(rec.error);
          if (rec.stackTrace != null) stderr.writeln(rec.stackTrace);
        }
      });
  }

  @override
  run() {
    var zone = Zone.current.fork(
        specification: new ZoneSpecification(
      print: (self, parent, zone, line) {
        logger.info(line);
      },
      handleUncaughtError: (self, parent, zone, error, stackTrace) {
        if (error is! UnimplementedError)
          logger.severe('FATAL ERROR', error, stackTrace);
      },
      errorCallback: (self, parent, zone, error, stackTrace) {
        self.handleUncaughtError(error, null);
      },
    ));

    return zone.run(() {
      var server = new BonoboLanguageServer(logger);
      logger.info('Bonobo language server started.');
      var stdio = new lsp.StdIOLanguageServer.start(server);
      return stdio.onDone;
    });
  }
}
