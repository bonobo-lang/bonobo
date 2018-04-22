/*
import 'package:bonobo/bonobo.dart';
import 'package:file/local.dart';
import 'package:parser/parser.dart';
import 'package:scanner/scanner.dart';

main(List<String> args) async {
  const options = const CompileOptions();
  CompilerInput input = await CompilerInput.fromOptions(options);
  var scanner = new Scanner(input.contents, sourceUrl: input.uri)..scan();
  print(scanner.errors);
  print(scanner.tokens.join('\n\n'));
  var parser = new Parser(scanner);
  var compilationUnit = parser.parseCompilationUnit();

  const fs = const LocalFileSystem();
  var directory = fs.directory(fs.currentDirectory);
  var moduleSystem = await BonoboModuleSystem.create(directory);
  var module = await moduleSystem.findModuleForFile(
      scanner.scanner.sourceUrl, moduleSystem.rootModule);

  var analyzer = new BonoboAnalyzer(moduleSystem);
  await analyzer.analyze(compilationUnit, input.uri, parser);

  print(analyzer.errors);

  // var analyzer = await analyze(new CompileOptions());
  // print(analyzer.module.scope.root.allPublicVariables);
}
*/
