part of bonobo.src.analysis;

class _BonoboStringType extends BonoboInheritedType {
  @override
  final String documentation = 'An immutable list of bytes, used to hold text.';

  static final c.CType _cType = new c.CType('String').pointer();

  _BonoboStringType() : super('String');

  @override
  c.CType get ctype => _cType;
}