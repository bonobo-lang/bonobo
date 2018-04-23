part of bonobo.src.analysis;

class _BonoboStringType extends BonoboInheritedType {
  @override
  final String documentation = 'An immutable list of bytes, used to hold text.';

  static final c.CType _cType = c.CType.char.const$().pointer();

  _BonoboStringType() : super('String');

  @override
  c.CType get ctype => _cType;

  @override
  BonoboType binaryOp(BinaryOperator operator, FileSpan, BonoboType other,
      BonoboAnalyzer analyzer) {
    return this;
  }
}
