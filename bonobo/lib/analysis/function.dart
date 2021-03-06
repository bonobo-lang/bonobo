part of bonobo.src.analysis;

class _BonoboFunctionType extends BonoboInheritedType {
  @override
  final String documentation = 'An executable unit of code.';

  static _BonoboFunctionType _instance;

  _BonoboFunctionType._(BonoboModule module) : super('Function', module);

  factory _BonoboFunctionType(BonoboModule module) =>
      _instance ??= new _BonoboFunctionType._(module);
}

class BonoboFunction extends BonoboObject {
  final List<BonoboFunctionParameter> parameters = [];
  final String name;
  final SymbolTable<BonoboObject> scope;
  final FunctionContext declaration;
  final BonoboModule declaringModule;
  ControlFlow body;
  BonoboType returnType;
  String manualDocs;
  BonoboFunctionType _type;

  BonoboFunction(this.name, this.scope, this.declaration, this.declaringModule)
      : super(new _BonoboFunctionType(null), declaration?.span);

  @override
  BonoboFunctionType get type {
    if (_type != null) return _type;
    var parameters = this.parameters.map((p) => p.type).toList();
    return _type =
        new BonoboFunctionType(declaringModule, parameters, returnType);
  }

  /// The fully-qualified name of this function.
  String get fullName {
    if (declaringModule.isRoot) return name;
    return declaringModule.fullName + '::$name';
  }

  String get documentation {
    if (manualDocs == null) return manualDocs;
    if (declaration == null) return '';
    if (declaration.comments.isNotEmpty)
      return declaration.comments.map((c) => c.text).join('\n');
    return type.signature;
  }
}

class BonoboNativeFunction extends BonoboFunction {
  final FutureOr Function(BinarySink) compile;
  final FutureOr Function(BonoboCCompiler, List<c.FunctionSignature> signatures)
      compileC;
  final FutureOr Function(SSACompiler compiler, SSACompilerState) compileSSA;

  BonoboNativeFunction(String name, BonoboModule declaringModule, this.compile,
      this.compileC, this.compileSSA)
      : super(name, null, null, declaringModule);
}

class BonoboFunctionParameter {
  final String name;
  final FileSpan span;
  BonoboType type;

  BonoboFunctionParameter(this.name, this.type, this.span);
}
