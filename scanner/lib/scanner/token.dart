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
  // new RegExp(r'\(\s*\)'): TokenType.parentheses,

  // Reserved
  'ret': TokenType.ret,
  'let': TokenType.let,
  'var': TokenType.var_,
  'const': TokenType.const_,
  'fn': TokenType.fn,
  'type': TokenType.type,
  'mixin': TokenType.mixin,
  'interface': TokenType.interface,

  'mixes': TokenType.mixes,
  'implements': TokenType.implements,

  'extern': TokenType.extern,

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
  '==': TokenType.equals,
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
  '=': TokenType.assign,

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
  // parentheses,

  // Reserved
  let,
  var_,
  const_,
  fn,
  ret,
  type,
  mixin,
  interface,

  mixes,
  implements,

  import,
  extern,

  // Modifiers
  hide_,

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
  l_and,
  l_or,
  equals,
  notEquals,
  question,
  lt,
  lte,
  gt,
  gte,
  shl,
  shr,
  dot,

  // Assignment
  assign,

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
