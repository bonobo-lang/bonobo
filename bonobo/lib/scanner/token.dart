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
  '[': TokenType.lBracket,
  ']': TokenType.rBracket,

  // Reserved
  'enum': TokenType.enum_,
  'ret': TokenType.ret,
  'let': TokenType.let,
  'var': TokenType.var_,
  'final': TokenType.final_,
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
  new RegExp(r'0x([A-Fa-f0-9]+)'): TokenType.hex,
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
  lBracket,
  rBracket,
  parentheses,

  // Reserved
  enum_,
  let,
  var_,
  final_,
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
  hex,
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

bool isAssignToken(TokenType t) =>
    {
      TokenType.assign: true,
      TokenType.assignAdd: true,
      TokenType.assignSub: true,
      TokenType.assignTimes: true,
      TokenType.assignDiv: true,
      TokenType.assignMod: true,
      TokenType.assignAnd: true,
      TokenType.assignOr: true,
      TokenType.assignXor: true,
      TokenType.assignShl: true,
      TokenType.assignShr: true,
    }[t] !=
    null;

bool isBinaryOpToken(TokenType t) =>
    {
      TokenType.mod: true,
      TokenType.pow: true,
      TokenType.times: true,
      TokenType.div: true,
      TokenType.plus: true,
      TokenType.minus: true,
      TokenType.xor: true,
      TokenType.and: true,
      TokenType.or: true,
      TokenType.l_and: true,
      TokenType.l_or: true,
      TokenType.equals: true,
      TokenType.notEquals: true,
      TokenType.lt: true,
      TokenType.lte: true,
      TokenType.gt: true,
      TokenType.gte: true,
      TokenType.shl: true,
      TokenType.shr: true,
    }[t] !=
    null;