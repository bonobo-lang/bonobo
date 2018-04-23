import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
import 'token.dart';
export 'token.dart';

class Scanner {
  final List<BonoboError> errors = [];
  final List<Token> tokens = [];
  final SpanScanner scanner;
  LineScannerState errorStart;
  ScannerState state = ScannerState.normal;
  FileSpan _emptySpan;

  static final RegExp whitespace = new RegExp(r'\s+');

  Scanner(String string, {sourceUrl})
      : scanner = new SpanScanner(string, sourceUrl: sourceUrl) {
    _emptySpan = scanner.emptySpan;
  }

  FileSpan get emptySpan => _emptySpan;

  void flush() {
    if (errorStart != null) {
      var span = scanner.spanFrom(errorStart);
      var message = 'Unexpected text "${span.text}".';

      if (span.text.trim() == ';')
        message = 'Semi-colons are illegal in Bonobo!';

      errors.add(new BonoboError(
        BonoboErrorSeverity.warning,
        message,
        span,
      ));
      errorStart = null;
    }
  }

  ScannerState scanNormalToken() {
    var tokens = <Token>[];

    if (scanner.scan(whitespace) && scanner.isDone) return ScannerState.normal;

    normalPatterns.forEach((pattern, type) {
      if (scanner.matches(pattern)) {
        tokens.add(new Token(type, scanner.lastSpan, scanner.lastMatch));
      }
    });

    if (tokens.isEmpty) {
      errorStart ??= scanner.state;
      scanner.readChar();
    } else {
      flush();
      tokens.sort((a, b) => b.span.length.compareTo(a.span.length));
      this.tokens.add(tokens.first);
      scanner.scan(tokens.first.span.text);
    }

    return ScannerState.normal;
  }

  void scan() {
    while (!scanner.isDone) {
      switch (state) {
        case ScannerState.normal:
          state = scanNormalToken();
          break;
      }
    }

    flush();
  }
}

enum ScannerState { normal }

class BonoboError implements Exception {
  final BonoboErrorSeverity severity;
  final String message;
  final FileSpan span;

  BonoboError(this.severity, this.message, this.span);

  @override
  String toString() {
    if (span == null) return message;
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
