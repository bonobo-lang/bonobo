part of bonobo.src.commands;

class FormatCommand extends Command {
  final String name = 'format';
  final String description =
      '(WIP) Formats a Bonobo file according to opinionated rules.';

  FormatCommand() : super() {
    argParser.addFlag(
      'lsp',
      help: 'Output edits in a Language Server Protocol-friendly JSON format.',
      negatable: false,
      defaultsTo: false,
    );
  }

  @override
  run() async {
    throw new UnimplementedError();
    //var tuple = await scanAndParse(this);
    // TODO: Actually format the text
    /* TODO
    var edits = <lsp.TextEdit>[];
    return edits;
    */
  }
}
