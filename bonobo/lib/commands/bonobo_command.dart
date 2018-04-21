part of bonobo.src.commands;

abstract class BonoboCommand<T> extends Command<T> {
  BonoboCommand() {
    argParser.addOption(
      'out',
      abbr: 'o',
      help: 'Specifies the output name for the file.',
    );
  }
}
