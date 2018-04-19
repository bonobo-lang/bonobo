part of bonobo.src.analysis;

class _BonoboFunctionType extends BonoboInheritedType {
  @override
  final String documentation = 'An executable unit of code.';

  static _BonoboFunctionType _instance;

  _BonoboFunctionType._() : super('Function');

  factory _BonoboFunctionType() => _instance ??= new _BonoboFunctionType._();
}

class BonoboFunction extends BonoboObject {
  final List<BonoboFunctionParameter> parameters = [];
  final String name;
  final SymbolTable<BonoboObject> scope;
  final FunctionContext declaration;
  ControlFlow body;
  BonoboType returnType;

  BonoboFunction(this.name, this.scope, this.declaration)
      : super(new _BonoboFunctionType(), declaration.span);

  String get documentation {
    if (declaration == null) return '';
    return declaration.comments.map((c) => c.text).join('\n');
  }

  String get signature {
    var b = new StringBuffer('f (');

    for (int i = 0; i < parameters.length; i++) {
      var p = parameters[i];

      if (i > 0) b.write(', ');
      b.write(p.name);

      if (p.type != null) {
        b.write(': ${p.type.name}');
      }
    }

    b.write(')');

    if (returnType != null) b.write(' => ${returnType.name}');

    return b.toString();
  }

  @override
  String toString() {
    return signature;
  }
}

class BonoboFunctionParameter {
  final String name;
  final FileSpan span;
  BonoboType type;

  BonoboFunctionParameter(this.name, this.span);
}
