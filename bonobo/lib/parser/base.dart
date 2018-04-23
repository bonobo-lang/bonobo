part of 'parser.dart';

final RegExp commentSlashes = new RegExp(r'///*');

class BaseParser {
  final List<BonoboError> errors = [];
  final Scanner scanner;
  int _index = -1;

  BaseParser(this.scanner) {
    errors.addAll(scanner.errors);
  }

  List<Token> computeRest() {
    if (done) return [];
    //print(_index);
    //print(scanner.tokens.skip(_index));
    return scanner.tokens.skip(_index).toList();
  }

  /// Joins the [tokens] into a single [FileSpan].
  FileSpan spanFrom(Iterable<Token> tokens) {
    return tokens.map((t) => t.span).reduce((a, b) => a.expand(b));
  }

  /// Returns `true` if there is no more input.
  bool get done => _index >= scanner.tokens.length - 1;

  /// Lookahead without consuming.
  Token peek() {
    if (done) return null;
    return scanner.tokens[_index + 1];
  }

  /// Lookahead and consume.
  Token consume() {
    if (done) return null;
    return scanner.tokens[++_index];
  }

  /// Attempts to scan a sequence of tokens, in the given order.
  ///
  /// Returns a [Queue] (LIFO), or `null`.
  Queue<Token> next(Iterable<TokenType> types) {
    if (_index > scanner.tokens.length - types.length - 1) return null;

    var tokens = new Queue<Token>();

    for (int i = 0; i < types.length; i++) {
      var token = scanner.tokens[_index + i + 1];

      if (token.type != types.elementAt(i)) return null;

      tokens.addFirst(token);
    }

    _index += types.length;
    return tokens;
  }

  /// Calls [next], only returning one [Token].
  Token nextToken(TokenType type) {
    return next([type])?.removeFirst();
    //return peek()?.type == type ? consume() : null;
  }

  Token nextIfOneOf(Iterable<TokenType> token) {
    Token t = peek();
    for (TokenType ch in token) {
      if (t.type == ch) {
        consume();
        return t;
      }
    }
    return null;
  }

  /// Parses available comments.
  List<Comment> parseComments() {
    var comments = <Comment>[];
    Token token;

    while ((token = nextToken(TokenType.comment)) != null) {
      var lines = token.match[1]
          .split('\n')
          .map((s) => s.replaceAll(commentSlashes, '').trim());
      comments.add(new Comment(lines.join('\n')));
    }

    return comments;
  }

  /// Runs [callback]. If the [callback] returns `null`, then the parser's
  /// position will be preserved, and any parse errors will be removed.
  T lookAhead<T>(T callback()) {
    var replay = _index;
    var result = callback();
    var len = errors.length;

    if (result == null) {
      _index = replay;

      if (errors.length > len) errors.removeRange(len, errors.length - 1);
    }

    return result;
  }
}
