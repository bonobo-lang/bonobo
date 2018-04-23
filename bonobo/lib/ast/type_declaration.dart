part of bonobo.src.ast;

/*
class TypeDeclarationContext extends AstNode {
  final SimpleIdentifierContext name;

  final bool isPriv;

  // TODO List<Generic> generics;

  // TODO List<Class> interfaces;

  // TODO List<Mixin> mixes;

  final List<VariableDeclarationStatementContext> fields;

  final List<FunctionContext> methods;

  TypeDeclarationContext(FileSpan span, this.name,
      {this.fields: const [], this.methods: const [], this.isPriv: false})
      : super(span, []);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitTypeDeclaration(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write('class');
    if (isPriv) sb.write(' hide');
    sb.write(' ${name.name}');
    // TODO generics
    // TODO interfaces
    // TODO mixins
    sb.writeln(' {');

    for (VariableDeclarationStatementContext st in fields) {
      sb.writeln(st);
      sb.writeln();
    }

    for (FunctionContext fn in methods) {
      sb.writeln(fn);
      sb.writeln();
    }

    sb.writeln('}');
    return sb.toString();
  }
}

class EnumValueContext extends AstNode {
  final SimpleIdentifierContext name;
  final NumberLiteralContext index;

  EnumValueContext(this.name, this.index, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitEnumValue(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write(name);
    if(index != null) sb.write(' = $index');
    return sb.toString();
  }
}

class EnumDeclarationContext extends AstNode {
  final SimpleIdentifierContext name;
  final List<EnumValueContext> values;

  EnumDeclarationContext(
      this.name, this.values, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitEnumDeclaration(this);

  String toString() {
    var sb = new StringBuffer();
    sb.writeln('enum $name {');
    sb.write(values.join(',\n'));
    sb.writeln();
    sb.writeln('}');
    return sb.toString();
  }
}
*/