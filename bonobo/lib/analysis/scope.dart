part of bonobo.src.analysis;

Future<SymbolTable<BonoboObject>> createRootScope(
    AnalysisContext context) async {
  var scope = new SymbolTable<BonoboObject>();

  return scope;
}

Future<Map<String, BonoboType>> createGlobalTypes(
    AnalysisContext context) async {
  return {
    BonoboType.Function$.name: BonoboType.Function$,
    BonoboType.Num.name: BonoboType.Num,
    BonoboType.String$.name: BonoboType.String$,
  };
}
