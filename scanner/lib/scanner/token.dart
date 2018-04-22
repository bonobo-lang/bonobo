import 'package:source_span/source_span.dart';

final RegExp doubleQuotedString = new RegExp(
    r'"((\\(["\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^"\\]))*"');

final RegExp singleQuotedString = new RegExp(
    r"'((\\(['\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^'\\]))*'");

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
  '[': TokenType.lSq,
  ']': TokenType.rSq,

  // Reserved
  'enum': TokenType.enum_,
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

  // Conditionals
  'if': TokenType.if_,
  'else': TokenType.else_,
  'elif': TokenType.elif_,
  'switch': TokenType.switch_,

  // Loops
  'loop': TokenType.loop,
  'for': TokenType.for_,
  'in': TokenType.in_,
  'while': TokenType.while_,

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
  '+=': TokenType.assignAdd,
  '-=': TokenType.assignSub,
  '*=': TokenType.assignTimes,
  '/=': TokenType.assignDiv,
  '%=': TokenType.assignMod,
  '&=': TokenType.assignAnd,
  '|=': TokenType.assignOr,
  '^=': TokenType.assignXor,
  '<<=': TokenType.assignShl,
  '>>=': TokenType.assignShr,

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
  lSq,
  rSq,
  parentheses,

  // Reserved
  enum_,
  let,
  var_,
  const_,
  fn,
  lambda,
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

  // Conditionals
  if_,
  else_,
  elif_,
  switch_,
  case_,
  default_,

  // Loops
  for_,
  in_,
  loop,
  while_,

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
  l_equals,
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
  assignAdd,
  assignSub,
  assignTimes,
  assignDiv,
  assignMod,
  assignAnd,
  assignOr,
  assignXor,
  assignShl,
  assignShr,

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
