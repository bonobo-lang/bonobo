library bonobo.src.ast;

import 'package:bonobo/analysis/analysis.dart';
import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import '../scanner/scanner.dart';

part 'unit.dart';

part 'expression.dart';

part 'function.dart';

part 'recursive_visitor.dart';

part 'statement.dart';

part 'type.dart';

part 'type_declaration.dart';

part 'visitor.dart';

abstract class AstNode {
  final FileSpan span;
  final List<Comment> comments;

  AstNode(this.span, this.comments);

  T accept<T>(BonoboAstVisitor<T> visitor);
}

abstract class Comment extends Token {
  Comment(FileSpan span, Match match) : super(TokenType.comment, span, match);

  String get text;
}

class SingleLineComment extends Comment {
  SingleLineComment(FileSpan span) : super(span, null);

  @override
  String get text => span.text.substring(2).trim();
}
