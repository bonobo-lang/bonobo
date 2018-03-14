part of bonobo.src.text;

 final RegExp doubleQuotedString = new RegExp(
    r'"((\\(["\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^"\\]))*"');

final RegExp singleQuotedString = new RegExp(
    r"'((\\(['\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^'\\]))*'");

class Scanner {
  final List<BonoboError> errors = [];
  final List<Token> tokens = [];
  final SpanScanner scanner;
  LineScannerState errorStart;
  ScannerState state = ScannerState.normal;
  FileSpan _emptySpan;

  static final RegExp whitespace = new RegExp(r'\s+');

  static final Map<Pattern, TokenType> normalPatterns = {
    // Misc.
    new RegExp(r'//([^\n]*)'): TokenType.comment,

    // Symbols
    '=>': TokenType.arrow,
    ':': TokenType.colon,
    ',': TokenType.comma,
    '{': TokenType.lCurly,
    '}': TokenType.rCurly,
    '(': TokenType.lParen,
    ')': TokenType.rParen,
    new RegExp(r'\(\s*\)'): TokenType.parentheses,

    // Reserved
    'f': TokenType.f,
    'print': TokenType.print,
    'ret': TokenType.ret,
    'v': TokenType.v,

    // Binary Operators
    '**': TokenType.pow,
    '*': TokenType.times,
    '/': TokenType.div,
    '+-': TokenType.plus_minus,

    // Assignments
    ':=': TokenType.colon_equals,
    '=': TokenType.equals,

    // Data
    new RegExp(r'[0-9]+(\.[0-9]+)?'): TokenType.number,
    singleQuotedString: TokenType.string,
    doubleQuotedString: TokenType.string,
    new RegExp(r'[A-Za-z_][A-Za-z0-9_]*'): TokenType.identifier,
  };

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
