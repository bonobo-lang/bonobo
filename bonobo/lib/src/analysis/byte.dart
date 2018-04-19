part of bonobo.src.analysis;

class _BonoboByteType extends BonoboInheritedType {
  _BonoboByteType() : super('Byte');

  @override
  c.CType get ctype => c.CType.char;

  @override
  BonoboType prefixOp(Token operator, BonoboAnalyzer analyzer) {
    var supportedOps = [TokenType.tilde, TokenType.plus, TokenType.minus];

    if (supportedOps.contains(operator.type)) return this;

    return super.prefixOp(operator, analyzer);
  }

  @override
  BonoboType binaryOp(
      Token operator, BonoboType other, BonoboAnalyzer analyzer) {
    var shiftOps = [TokenType.shl, TokenType.shr];
    var supportedOps = [
      TokenType.pow,
      TokenType.times,
      TokenType.div,
      TokenType.mod,
      TokenType.plus,
      TokenType.minus,
      TokenType.xor,
      TokenType.and,
      TokenType.or,
    ];

    // TODO: Use `Int`, instead of `Num`, which is being phased out.
    if (shiftOps.contains(operator.type) &&
        other.isAssignableTo(BonoboType.Num)) return this;

    if (supportedOps.contains(operator.type) && other.isAssignableTo(this))
      return this;

    return super.prefixOp(operator, analyzer);
  }
}
