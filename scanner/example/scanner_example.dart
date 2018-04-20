import 'package:scanner/scanner.dart';

main() async {
  Source src = await Source.fromPath('../example/hello/main.bnb');
  var scanner = new Scanner(src.contents, sourceUrl: src.uri);
  scanner.scan();
  print(scanner.errors);
  print(scanner.tokens.join('\n\n'));
}
