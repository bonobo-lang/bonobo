import 'package:bonobo/bonobo.dart';

main(List<String> args) async {
  const options = const CompileOptions();
  CompilerInput input = await CompilerInput.fromOptions(options);
  var scanner = new Scanner(input.contents, sourceUrl: input.uri)..scan();
  // var analyzer = await analyze(new CompileOptions());
  // print(analyzer.module.scope.root.allPublicVariables);
}