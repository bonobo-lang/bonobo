part of bonobo.src.analysis;

// TODO: Fields, getters/setters, etc.
// TODO: fullName getter based on module system.
abstract class BonoboType {
  static final BonoboType Root = new _BonoboRootType();
  static final BonoboType Byte = new _BonoboByteType();
  static final BonoboType Function$ = new _BonoboFunctionType();
  static final BonoboType Num = new _BonoboNumType();
  static final BonoboType String$ = new _BonoboStringType();
  final List<SymbolUsage> usages = [];

  String get documentation => null;

  static BonoboType findCommonAncestor(BonoboType a, BonoboType b) {
    BonoboType compare = b;

    // Try comparisons, left to right
    do {
      if (a == compare) return compare;
      compare = compare.parent;
    } while (!compare.isRoot);

    // Try comparisons, right to left
    compare = a;
    do {
      if (b == compare) return compare;
      compare = compare.parent;
    } while (!compare.isRoot);

    // Other
    return Root;
  }

  String get name;

  BonoboType get parent;

  bool get isRoot;

  c.CType get ctype;

  @override
  bool operator ==(other) {
    // TODO: As type system gets fleshed out,
    // there'll need to be unique names for each type.
    if (other is! BonoboType)
      return false;
    else {
      var o = other as BonoboType;
      return o.parent == parent && o.name == name /* TODO && o.span == span */;
    }
  }

  /// Returns `true` if the two types share a common ancestor that is **not** the [Root] type.
  bool isAssignableTo(BonoboType other) {
    return other == Root || findCommonAncestor(this, other) != Root;
  }

  /// Returns the type of the result of applying the given prefix [operator].
  BonoboType prefixOp(Token operator, BonoboAnalyzer analyzer) {
    analyzer.errors.add(new BonoboError(BonoboErrorSeverity.error,
        "Invalid prefix operator '${operator.span.text}'.", operator.span));
    return Root;
  }

  /// Returns the type of the result of applying the given binary [operator].
  BonoboType binaryOp(
      Token operator, BonoboType other, BonoboAnalyzer analyzer) {
    // Booleans should return bool
    // TODO: Bool type
    var booleanOps = [];

    if (booleanOps.contains(operator.type)) return BonoboType.Byte;

    analyzer.errors.add(new BonoboError(BonoboErrorSeverity.error,
        "Invalid binary operator '${operator.span.text}'.", operator.span));
    return Root;
  }

  /// Returns the type of the result of applying the given postfix [operator].
  BonoboType postfixOp(Token operator, BonoboAnalyzer analyzer) {
    analyzer.errors.add(new BonoboError(BonoboErrorSeverity.error,
        "Invalid postfix operator '${operator.span.text}'.", operator.span));
    return Root;
  }

  BonoboType unsupportedBinaryOperator(
      Token operator, BonoboType other, BonoboAnalyzer analyzer) {
    analyzer.errors.add(new BonoboError(
        BonoboErrorSeverity.error,
        "$name does not support running the '${operator.span.
          text}' operator against ${other.name}.",
        operator.span));
    return Root;
  }
}

class _BonoboRootType extends BonoboType {
  @override
  String get name => '?';

  @override
  BonoboType get parent => this;

  @override
  c.CType get ctype {
    // todo: is it smart to return a void* for undefined types?
    return c.CType.void$.pointer();
  }

  @override
  bool get isRoot => true;
}

class BonoboInheritedType extends BonoboType {
  final String name;
  final BonoboType parent;

  BonoboInheritedType(this.name, [BonoboType parent])
      : parent = parent ?? BonoboType.Root;

  @override
  c.CType get ctype => null;

  bool get isRoot => false;

  @override
  BonoboType unsupportedBinaryOperator(
      Token operator, BonoboType other, BonoboAnalyzer analyzer) {
    return parent.unsupportedBinaryOperator(operator, other, analyzer);
  }

  @override
  BonoboType postfixOp(Token operator, BonoboAnalyzer analyzer) {
    return parent.postfixOp(operator, analyzer);
  }

  @override
  BonoboType binaryOp(
      Token operator, BonoboType other, BonoboAnalyzer analyzer) {
    return parent.binaryOp(operator, other, analyzer);
  }

  @override
  BonoboType prefixOp(Token operator, BonoboAnalyzer analyzer) {
    return parent.prefixOp(operator, analyzer);
  }
}