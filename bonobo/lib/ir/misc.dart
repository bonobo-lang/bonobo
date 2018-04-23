part of bonobo.ir;

@Serializable(autoIdAndDateFields: false)
class _Span {
  String sourceUrl;
  _Location start, end;
}

@Serializable(autoIdAndDateFields: false)
class _Location {
  int line, character;
}