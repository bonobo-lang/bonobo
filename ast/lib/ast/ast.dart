library bonobo.src.ast;

import 'package:bonobo/bonobo.dart';
import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:scanner/scanner.dart';

part 'unit.dart';
part 'expression.dart';
part 'function.dart';
part 'recursive_visitor.dart';
part 'statement.dart';
part 'type.dart';
part 'visitor.dart';

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