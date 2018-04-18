import 'package:bonobo/bonobo.dart';

main(List<String> args) async {
  var analyzer = await analyze(new CompileOptions());

  print(analyzer.module.scope.root.allPublicVariables);
}