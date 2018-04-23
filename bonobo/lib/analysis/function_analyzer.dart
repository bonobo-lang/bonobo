part of bonobo.src.analysis;

class FunctionAnalyzer {
  final BonoboAnalyzer analyzer;

  FunctionAnalyzer(this.analyzer);

  Future populateFunctionSignature(BonoboFunction function) async {
    for (int i = 0; i < function.parameters.length; i++) {
      var p = function.parameters[i];
      var decl = function.declaration.signature.parameterList.parameters[i];
      p.type = await analyzer.typeAnalyzer.resolve(decl.type);
      function.scope.assign(p.name, new BonoboObject(p.type, p.span))
        ..value
            .usages
            .add(new SymbolUsage(SymbolUsageType.declaration, decl.name.span));

      if (decl.type != null) {
        p.type.usages
            .add(new SymbolUsage(SymbolUsageType.read, decl.type.span));
      }
    }

    if (function.declaration.signature.returnType != null) {
      function.returnType = await analyzer.typeAnalyzer
          .resolve(function.declaration.signature.returnType);
      function.returnType.usages.add(new SymbolUsage(SymbolUsageType.read,
          function.declaration.signature.returnType.span));
    } else
      function.returnType = BonoboType.Root;
  }

  Future analyzeFunction(BonoboFunction function) async {
    function.body =
        await analyzer.statementAnalyzer.analyzeControlFlow(function);

    if (function.declaration.signature.returnType == null) {
      // Attempt to infer the return type, if none is specified
      function.returnType = function.body.returnType ?? BonoboType.Root;
    }
  }
}
