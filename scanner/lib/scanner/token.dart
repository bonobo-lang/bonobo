part of 'scanner.dart';

final Map<Pattern, TokenType> normalPatterns = {
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
  'ret': TokenType.ret,
  'func': TokenType.func,
  'var': TokenType.v,
  'class': TokenType.clazz,
  'mixin': TokenType.mixin,
  'interface': TokenType.interface,

  'extern': TokenType.extern,

  // Modifiers
  'pub': TokenType.pub,

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
  '&&': TokenType.b_and,
  '||': TokenType.b_or,
  '==': TokenType.b_equals,
  '!=': TokenType.b_not_equals,
  '?': TokenType.question,
  '<': TokenType.lt,
  '<=': TokenType.lte,
  '>': TokenType.gt,
  '>=': TokenType.gte,
  '<<': TokenType.shl,
  '>>': TokenType.shr,
  '.': TokenType.dot,

  // Assignments
  ':=': TokenType.colon_equals,
  '=': TokenType.equals,

  // Data
  new RegExp(r'[0-9]+((\.[0-9]+)|b)?'): TokenType.number,
  singleQuotedString: TokenType.string,
  doubleQuotedString: TokenType.string,
  new RegExp(r'[A-Za-z_][A-Za-z0-9_]*'): TokenType.identifier,
};

enum TokenType {
  // Misc.
  comment,

  // Symbols
  arrow,
  colon,
  comma,
  double_colon,
  lCurly,
  rCurly,
  lParen,
  rParen,
  parentheses,

  // Reserved
  func,
  ret,
  v,
  clazz,
  mixin,
  interface,


  import,
  extern,

  // Modifiers
  pub,

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
  dot,

  // Assignment
  colon_equals,
  equals,

  // Data
  number,
  string,
  identifier,
}

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

const List<TokenType> modifierTypes = const [
  TokenType.pub,
];
