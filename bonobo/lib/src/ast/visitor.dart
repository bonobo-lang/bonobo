part of bonobo.src.ast;

/// A visitor that produces some representation of a Bonobo source tree.
abstract class BonoboAstVisitor<T> {
  T visit(AstNode node) => node.accept(this);

  T visitCompilationUnit(CompilationUnitContext ctx);

  T visitTypedef(TypedefContext ctx);

  T visitFunction(FunctionContext ctx);

  T visitType(TypeContext ctx);

  T visitSimpleIdentifierType(
      SimpleIdentifierTypeContext simpleIdentifierTypeContext);

  T visitNamespacedIdentifierType(
      NamespacedIdentifierTypeContext namespacedIdentifierTypeContext);

  T visitTupleType(TupleTypeContext tupleTypeContext);

  T visitParenthesizedType(ParenthesizedTypeContext parenthesizedTypeContext);

  T visitFunctionType(FunctionTypeContext functionTypeContext);

  T visitSimpleIdentifier(SimpleIdentifierContext simpleIdentifierContext);

  T visitNamespacedIdentifier(
      NamespacedIdentifierContext namespacedIdentifierContext);

  T visitNumberLiteral(NumberLiteralContext numberLiteralContext);

  T visitStringliteral(StringLiteralContext stringLiteralContext);

  T visitPrintExpression(PrintExpressionContext printExpressionContext);

  T visitParenthesizedExpression(
      ParenthesizedExpressionContext parenthesizedExpressionContext);

  T visitPrefixExpression(PrefixExpressionContext prefixExpressionContext);

  T visitPostfixExpression(PostfixExpressionContext postfixExpressionContext);

  T visitAssignmentExpression(
      AssignmentExpressionContext assignmentExpressionContext);

  T visitBinaryExpression(BinaryExpressionContext binaryExpressionContext);

  T visitConditionalExpression(
      ConditionalExpressionContext conditionalExpressionContext);

  T visitTupleExpression(TupleExpressionContext tupleExpressionContext);

  T visitCallExpression(CallExpressionContext callExpressionContext);

  T visitMemberExpression(MemberExpressionContext memberExpressionContext);

  T visitBlock(BlockContext blockContext);

  T visitExpressionStatement(
      ExpressionStatementContext expressionStatementContext);

  T visitReturnStatement(ReturnStatementContext returnStatementContext);

  T visitVariableDeclarationStatement(
      VariableDeclarationStatementContext variableDeclarationStatementContext);

  T visitVariableDeclaration(
      VariableDeclarationContext variableDeclarationContext);

  T visitFunctionSignature(FunctionSignatureContext functionSignatureContext);

  T visitBlockFunctionBody(BlockFunctionBodyContext blockFunctionBodyContext);

  T visitLambdaFunctionBody(
      LambdaFunctionBodyContext lambdaFunctionBodyContext);

  T visitParameterList(ParameterListContext parameterListContext);

  T visitParameter(ParameterContext parameterContext);
}
