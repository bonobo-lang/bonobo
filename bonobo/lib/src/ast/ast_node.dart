part of bonobo.src.ast;

abstract class AstNode {
  final FileSpan span;
  final List<Comment> comments;

  AstNode(this.span, this.comments);

  T accept<T>(BonoboAstVisitor<T> visitor);
}

class Comment {
  final String text;
  Comment(this.text);
}