import 'package:matcher/matcher.dart';
import 'package:scanner/scanner.dart';

Matcher scans({int count, List<TokenType> tokens}) {
  assert(count != null || tokens != null);
  return new _Scans(count, tokens);
}

class _Scans extends Matcher {
  final int count;
  final List<TokenType> tokens;

  _Scans(this.count, this.tokens);

  @override
  bool matches(item, Map matchState) {
    var scanner = new Scanner(item.toString());
    scanner.scan();
    var matches = true;

    if (count != null) matches = scanner.tokens.length == count;

    if (tokens != null)
      matches = equals(tokens)
          .matches(scanner.tokens.map((t) => t.type).toList(), matchState);

    return matches;
  }

  @override
  Description describe(Description description) {
    if (count != null)
      description = description.add('scans exactly $count token(s)');

    if (tokens != null)
      description =
          description.add('scans exactly this sequence of tokens: $tokens');
    return description;
  }
}
