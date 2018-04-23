part of bonobo.src.analysis;

class TypeAnalyzer {
  final BonoboAnalyzer analyzer;

  TypeAnalyzer(this.analyzer);

  Future<BonoboType> resolve(TypeContext ctx) async {
    if (ctx == null)
      return BonoboType.Root;
    else if (ctx is NamedTypeContext) {
      BonoboModule m = analyzer.module;

      do {
        var existing = m.types[ctx.identifier.name];

        if (existing != null) return existing;
        m = m.parent;
      } while (m != null);

      analyzer.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Unknown type '${ctx.identifier.name}'.", ctx.span));

      return BonoboType.Root;
    } else if (ctx is StructTypeContext) {
      var fields = <String, BonoboType>{};

      for (var field in ctx.fields) {
        fields[field.name.name] = await resolve(field.type);
      }

      return new BonoboStructType(fields);
    } else if (ctx is EnumTypeContext) {
      var values = ctx.values
          .map((v) => new BonoboEnumValue(v.name.name, v.index?.intValue))
          .toList();
      return new BonoboEnumType(values);
    } else if (ctx is TupleTypeContext) {
      var types = await Future.wait(ctx.items.map(resolve));
      return new BonoboTupleType(types);
    } else if (ctx is FunctionTypeContext) {
      var parameters = await Future.wait(ctx.parameters.map(resolve));
      var returnType = await resolve(ctx.returnType);
      return new BonoboFunctionType(parameters, returnType);
    } else if (ctx is ParenthesizedTypeContext) {
      return await resolve(ctx.innermost);
    } else {
      analyzer.errors.add(new BonoboError(BonoboErrorSeverity.warning,
          'Unsupported type: ${ctx.runtimeType}', ctx.span));
      return BonoboType.Root;
    }
  }
}
