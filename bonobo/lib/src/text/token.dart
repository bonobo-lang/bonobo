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
  //elvis_equals,
  mod_equals,
  tilde_equals,
  pow_equals,
  times_equals,
  div_equals,
  plus_minus_equals,
  plus_equals,
  minus_equals,
  xor_equals,
  and_equals,
  or_equals,
  b_and_equals,
  b_or_equals,
  colon_equals,
  equals,

  // Data
  number,
  string,
  identifier,
}

const List<TokenType> assignmentOperators = const [
  //TokenType.elvis_equals,
  TokenType.mod_equals,
  TokenType.tilde_equals,
  TokenType.pow_equals,
  TokenType.times_equals,
  TokenType.div_equals,
  TokenType.plus_minus_equals,
  TokenType.plus_equals,
  TokenType.minus_equals,
  TokenType.xor_equals,
  TokenType.and_equals,
  TokenType.or_equals,
  TokenType.b_and_equals,
  TokenType.b_or_equals,
  TokenType.colon_equals,
  TokenType.equals,
];
