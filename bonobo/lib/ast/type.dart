part of bonobo.src.ast;

abstract class TypeContext extends AstNode {
  TypeContext(FileSpan span, List<Comment> comments) : super(span, comments);
}

class IdentifierTypeContext extends TypeContext {
  final IdentifierContext identifier;

  IdentifierTypeContext(this.identifier, List<Comment> comments)
      : super(identifier.span, comments);
}
