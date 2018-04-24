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

class MultiLineComment extends Comment {
  final List<MultiLineCommentMember> members;

  static final RegExp _star = new RegExp(r'^\*');

  MultiLineComment(this.members, FileSpan span) : super(span, null);

  static String stripStars(String s) {
    var lines = s.split('\n').where((s) => s.isNotEmpty);
    return lines.map((s) => s.trim().replaceAll(_star, '').trim()).join('\n');
  }

  @override
  String get text {
    return members.map((m) => m.text.trim()).join('\n').trim();
  }
}

abstract class MultiLineCommentMember {
  FileSpan get span;

  String get text;
}

class MultiLineCommentText extends MultiLineCommentMember {
  final FileSpan span;

  MultiLineCommentText(this.span);

  @override
  String get text => MultiLineComment.stripStars(span.text);
}

class NestedMultiLineComment extends MultiLineCommentMember {
  final MultiLineComment comment;

  NestedMultiLineComment(this.comment);

  @override
  FileSpan get span => comment.span;

  @override
  String get text => comment.text;
}
