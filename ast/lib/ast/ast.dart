library bonobo.src.ast;

import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:scanner/scanner.dart';

part 'unit.dart';
part 'expression.dart';
part 'function.dart';
part 'statement.dart';
part 'type.dart';

abstract class AstNode {
  final FileSpan span;
  final List<Comment> comments;

  AstNode(this.span, this.comments);
}

class Comment {
  final String text;
  Comment(this.text);
}
