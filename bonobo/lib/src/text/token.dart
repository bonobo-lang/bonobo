part of bonobo.src.text;

class Token {
  final TokenType type;
  final FileSpan span;
  final Match match;

  Token(this.type, this.span, this.match);

  @override
  String toString() {
    return '$type: ${span.start.toolString}: "${span.text}"\n${span
        .highlight()}';
  }
}

enum TokenType {
  // Misc.
  comment,

  // Symbols
  arrow,
  colon,
  comma,
  lCurly,
  rCurly,
  lParen,
  rParen,
  parentheses,

  // Reserved
  f,
  print,
  ret,
  v,

  // Modifiers
  pub,
  priv,

  // Unary operators
  increment,
  decrement,
  not,

  // Binary Operators
  //elvis,
  mod,
  tilde,
  pow,
  times,
  div,
  plus_minus,
  plus,
  minus,
  xor,
  and,
  or,
  b_and,
  b_or,
  b_equals,
  b_not_equals,
  question,
  lt,
  lte,
  gt,
  gte,
  shl,
  shr,

  // Assignment
  colon_equals,
  equals,

  // Data
  number,
  string,
  identifier,
}

const List<TokenType> modifierTypes = const [
  TokenType.pub,
  TokenType.priv,
];