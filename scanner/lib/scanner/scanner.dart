import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
import 'token.dart';

class Scanner {
  final List<BonoboError> errors = [];
  final List<Token> tokens = [];
  final SpanScanner scanner;
  LineScannerState errorStart;
  ScannerState state = ScannerState.normal;
  FileSpan _emptySpan;

  static final RegExp whitespace = new RegExp(r'\s+');

  /*
  static final Map<Pattern, TokenType> normalPatterns = {
    // Misc.
    new RegExp(r'//([^\n]*)'): TokenType.comment,

    // Symbols
    '=>': TokenType.arrow,
    ':': TokenType.colon,
    ',': TokenType.comma,
    '::': TokenType.double_colon,
    '{': TokenType.lCurly,
    '}': TokenType.rCurly,
    '(': TokenType.lParen,
    ')': TokenType.rParen,
    new RegExp(r'\(\s*\)'): TokenType.parentheses,

    // Reserved
    'fn': TokenType.fn,
    'lambda': TokenType.lambda,
    'let': TokenType.let,
    'type': TokenType.type,
    'ret': TokenType.ret,

    // Modifiers
    'hide': TokenType.hide_,

    // Unary operators
    '++': TokenType.increment,
    '--': TokenType.decrement,
    '!': TokenType.not,

    // Binary Operators
    '%': TokenType.mod,
    '~': TokenType.tilde,
    '**': TokenType.pow,
    '*': TokenType.times,
    '/': TokenType.div,
    '+': TokenType.plus,
    '-': TokenType.minus,
    '±': TokenType.plus_minus,
    '+-': TokenType.plus_minus,
    '^': TokenType.xor,
    '&': TokenType.and,
    '|': TokenType.or,
    '&&': TokenType.l_and,
    '||': TokenType.l_or,
    '==': TokenType.l_equals,
    '!=': TokenType.notEquals,
    '?': TokenType.question,
    '<': TokenType.lt,
    '<=': TokenType.lte,
    '>': TokenType.gt,
    '>=': TokenType.gte,
    '<<': TokenType.shl,
    '>>': TokenType.shr,
    '.': TokenType.dot,

    // Assignments
    //':=': TokenType.colon_equals,
    '=': TokenType.equals,

    // Data
    new RegExp(r'[0-9]+((\.[0-9]+)|b)?'): TokenType.number,
    singleQuotedString: TokenType.string,
    doubleQuotedString: TokenType.string,
    new RegExp(r'[A-Za-z_][A-Za-z0-9_]*'): TokenType.identifier,
  };*/

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
