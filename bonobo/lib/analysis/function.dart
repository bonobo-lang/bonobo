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
  final BonoboModule declaringModule;
  ControlFlow body;
  BonoboType returnType;
  BonoboFunctionType _type;

  BonoboFunction(this.name, this.scope, this.declaration, this.declaringModule)
      : super(new _BonoboFunctionType(), declaration.span);

  @override
  BonoboFunctionType get type {
    if (_type != null) return _type;

    var parameters = this.parameters.map((p) => p.type).toList();
    return _type = new BonoboFunctionType(parameters, returnType);
  }

  /// The fully-qualified name of this function.
  String get fullName {
    if (declaringModule.isRoot) return name;
    return declaringModule.fullName + '.$name';
  }

  String get documentation {
    if (declaration == null) return '';
    return declaration.comments.map((c) => c.text).join('\n');
  }
}

class BonoboFunctionParameter {
  final String name;
  final FileSpan span;
  BonoboType type;

  BonoboFunctionParameter(this.name, this.span);
}
