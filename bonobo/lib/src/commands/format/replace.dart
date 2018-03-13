part of bonobo.src.commands;

String removeQuotesFromString(String s) {
  if (s.length <= 1) return s;
  if (s.length == 2) return '';
  return s.substring(1, s.length - 1);
}

/// Nit-picks the source code, replacing things like quotes and comments.
String lintReplace(String string) {
  return string
      .replaceAll(commentSlashes, '//')
      .replaceAllMapped(doubleQuotedString, (m) {
    // Only replace with single quotes if there are no single quotes contained.
    if (m[0].contains("'")) return m[0];
    return "'" + removeQuotesFromString(m[0]) + "'";
  }).replaceAllMapped(singleQuotedString, (m) {
    // Only replace with double quotes if there ARE escaped single quotes contained.
    if (m[0].contains("\\'")) return m[0];
    return '"' + removeQuotesFromString(m[0]).replaceAll("\\'", "'") + '"';
  });
}
