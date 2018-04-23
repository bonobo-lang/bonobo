part of bonobo.src.analysis;

class _BonoboByteType extends BonoboInheritedType {
  _BonoboByteType() : super('Byte');

  @override
  c.CType get ctype => c.CType.char;

  @override
  BonoboType prefixOp(PrefixOperatorContext operator, BonoboAnalyzer analyzer) {
    var supportedOps = [
      PrefixOperator.complement,
      PrefixOperator.plus,
      PrefixOperator.minus
    ];

    if (supportedOps.contains(operator)) return this;

    return super.prefixOp(operator, analyzer);
  }

  @override
  BonoboType binaryOp(BinaryOperator operator, FileSpan span, BonoboType other,
      BonoboAnalyzer analyzer) {
    var shiftOps = [BinaryOperator.shl, BinaryOperator.shr];
    var supportedOps = [
      BinaryOperator.pow,
      BinaryOperator.times,
      BinaryOperator.div,
      BinaryOperator.mod,
      BinaryOperator.plus,
      BinaryOperator.minus,
      BinaryOperator.xor,
      BinaryOperator.and,
      BinaryOperator.or,
    ];

    // TODO: Use `Int`, instead of `Num`, which is being phased out.
    if (shiftOps.contains(operator) && other.isAssignableTo(BonoboType.Num))
      return this;

    if (supportedOps.contains(operator) && other.isAssignableTo(this))
      return this;

    return super.binaryOp(operator, span, other, analyzer);
  }
}
