part of 'analysis.dart';

class BonoboAnalyzer {
  final List<BonoboError> errors = [];
  final BonoboModuleSystem moduleSystem;
  ExpressionAnalyzer expressionAnalyzer;
  FunctionAnalyzer functionAnalyzer;
  StatementAnalyzer statementAnalyzer;
  TypeAnalyzer typeAnalyzer;

  //final Parser parser;
  BonoboModule module;

  final Map<SourceLocation, BonoboObject> expressionCache = {};

  BonoboAnalyzer(this.moduleSystem) {
    expressionAnalyzer = new ExpressionAnalyzer(this);
    functionAnalyzer = new FunctionAnalyzer(this);
    statementAnalyzer = new StatementAnalyzer(this);
    typeAnalyzer = new TypeAnalyzer(this);
  }

  // TODO: Find unused symbols
  Future analyze(
      CompilationUnitContext compilationUnit, Uri sourceUrl, Parser parser,
      [BonoboModule m]) async {
    var functions = <BonoboFunction>[];

    // Figure out which module we're even working in...
    module = m ??
        await moduleSystem.findModuleForFile(
            sourceUrl, moduleSystem.rootModule);
    //module = moduleSystem.rootModule;

    if (module.compilationUnits[sourceUrl] != null) {
      return;
    }

    module.compilationUnits[sourceUrl] = compilationUnit;
    errors.addAll(parser.errors);

    // Get the names of all types that are not typedefs.
    // TODO: Custom classes, etc.

    // Next, find the names of all typedefs.
    for (var typedef in compilationUnit.typedefs) {
      // For each typedef, create an empty one in the module's
      // type dictionary.
      //
      // This will be populated, but this allows for forward references, etc.
      var existing = module.types[typedef.name.name];

      if (existing != null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Typedef '${typedef.name
                .name}' conflicts with the name of an existing type.",
            typedef.span));

        if (existing.span != null) {
          errors.add(new BonoboError(
              BonoboErrorSeverity.warning,
              "A typedef declared elsewhere conflicts with this type.",
              existing.span));
        }
      } else if (existing == null) {
        module.types[typedef.name.name] =
            new BonoboTypedef(typedef.name.name, typedef.span);
      }
    }

    // Populate any typedefs.
    for (var typedef in compilationUnit.typedefs) {
      var type = module.types[typedef.name.name];
      if (type is BonoboTypedef) {
        type.type = await typeAnalyzer.resolve(typedef.type);
      }
    }

    // Get the names of all functions
    for (var ctx in compilationUnit.functions) {
      try {
        functions.add(functionAnalyzer.preliminaryAnalyzeFunction(ctx));
      } on StateError catch (e) {
        errors.add(
            new BonoboError(BonoboErrorSeverity.error, e.message, ctx.span));
      }
    }

    // Collect signature information.
    for (var ctx in functions) {
      await functionAnalyzer.populateFunctionSignature(ctx);
    }

    // Now, analyze them fully.
    for (var ctx in functions) {
      await functionAnalyzer.analyzeFunction(ctx);
    }
  }
}
