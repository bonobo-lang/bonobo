part of bonobo.src.commands;

class DocumentCommand extends BonoboCommand {
  final String name = 'document';
  final String description =
      'Generates (very basic) documentation for a Bonobo project.';

  @override
  run() async {
    var analyzer = await analyze(this);
    if (analyzer == null) return null;

    var b = new CodeBuffer();

    b
      ..writeln('<!DOCTYPE html>')
      ..writeln('<html>')
      ..indent()
      ..writeln('<body>')
      ..indent()
      ..outdent()
      ..writeln('</body>')
      ..outdent()
      ..writeln('</html>');

    getOutput(this)
      ..write(b)
      ..close();
  }
}
