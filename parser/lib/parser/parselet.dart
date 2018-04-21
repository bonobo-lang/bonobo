/*
import 'package:ast/ast.dart';
import 'package:scanner/scanner.dart';
import 'package:scanner/scanner.dart';

import 'parser.dart';


typedef T PrefixParselet<T>(Parser parser, Token token,
    List<Comment> comments, bool inVariableDeclaration);

class InfixParselet<T> {
  final int precedence;

  final T Function(Parser parser, T left,
      Token token, List<Comment> comments, bool inVariableDeclaration) parse;

  const InfixParselet(this.precedence, this.parse);
}

class BinaryParselet extends InfixParselet<ExpressionContext> {
  BinaryParselet(int precedence)
      : super(precedence,
            (parser, left, token, comments, inVariableDeclaration) {
          var span = left.span.expand(token.span), lastSpan = span;
          var equals = token.type == TokenType.equals
              ? null
              : parser.nextToken(TokenType.equals)?.span;

          if (equals != null) {
            span = span.expand(lastSpan = equals);
          }

          var right = parser.parseExpression();
          //var right = parser.parseExpression(0, inVariableDeclaration);

          if (right == null) {
            parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing expression after '${lastSpan.text}'.", lastSpan));
            return null;
          }

          span = span.expand(right.span);

          if (equals != null || token.type == TokenType.equals) {
            return new AssignmentExpressionContext(
              left,
              token,
              right,
              span,
              []..addAll(comments)..addAll(right.comments),
            );
          }

          //return new BinaryExpressionContext(span, comments, left, right, op);
          /*
          return new BinaryExpressionContext(
            left,
            token,
            right,
            span,
            []..addAll(comments)..addAll(right.comments),
          );*/
        });
}
*/
