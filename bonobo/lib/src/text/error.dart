part of bonobo.src.text;

class BonoboError implements Exception {
  final BonoboErrorSeverity severity;
  final String message;
  final FileSpan span;

  BonoboError(this.severity, this.message, this.span);

  @override
  String toString() {
    return '${span.start.toolString}: $message';
  }
}

String severityToString(BonoboErrorSeverity severity) {
  switch (severity) {
    case BonoboErrorSeverity.warning:
      return 'warning';
    case BonoboErrorSeverity.error:
      return 'error';
    case BonoboErrorSeverity.information:
      return 'info';
    case BonoboErrorSeverity.hint:
      return 'hint';
    default:
      throw new ArgumentError();
  }
}

enum BonoboErrorSeverity { warning, error, information, hint }
