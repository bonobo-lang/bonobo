import 'package:file/local.dart';
import 'package:scanner/scanner.dart';

main() async {
  const fs = const LocalFileSystem();
  Source src = await Source.fromPath(fs, '../example/hello/main.bnb');
  var scanner = new Scanner(src.contents, sourceUrl: src.uri);
  scanner.scan();
  print(scanner.errors);
  print(scanner.tokens.join('\n\n'));
}
