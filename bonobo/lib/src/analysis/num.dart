part of bonobo.src.analysis;

class _BonoboNumType extends BonoboInheritedType {
  @override
  final String documentation = 'A number of variable size.';

  static final c.CType _cType = c.CType.int64_t;

  _BonoboNumType() : super('Num');

  @override
  c.CType get ctype => _cType;
}