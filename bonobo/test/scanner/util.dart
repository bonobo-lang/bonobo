import 'package:matcher/matcher.dart';
import 'package:bonobo/scanner/scanner.dart';

Matcher scans({int count, List<TokenType> tokens, List<String> text}) {
  assert(count != null || tokens != null || text != null);
  return new _Scans(count, tokens, text);
}

Matcher scansOne(TokenType type, [String text]) =>
    scans(count: 1, tokens: [type], text: text == null ? null : [text]);

class _Scans extends Matcher {
  final int count;
  final List<TokenType> tokens;
  final List<String> text;

  _Scans(this.count, this.tokens, this.text);

  @override
  bool matches(item, Map matchState) {
    var scanner = new Scanner(item.toString());
    scanner.scan();
    var matches = true;

    if (count != null) matches = scanner.tokens.length == count;

    if (tokens != null)
      matches = matches &&
          equals(tokens)
              .matches(scanner.tokens.map((t) => t.type).toList(), matchState);

    if (text != null)
      matches = matches &&
          equals(text).matches(
              scanner.tokens.map((t) => t.span.text).toList(), matchState);

    return matches;
  }

  @override
  Description describe(Description description) {
    if (count != null)
      description = description.add('scans exactly $count token(s)');

    if (tokens != null)
      description =
          description.add(' scans exactly this sequence of tokens: $tokens');

    if (text != null)
      description =
          description.add(' scans exactly this sequence of text: $text');

    return description;
  }
}
