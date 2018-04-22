part of bonobo.src.ast;

/// A visitor that produces some representation of a Bonobo source tree.
abstract class BonoboAstVisitor<T> {
  T visit(AstNode node) => node.accept(this);

  T visitCompilationUnit(CompilationUnitContext ctx);

  T visitTypedef(TypedefContext ctx);

  T visitFunction(FunctionContext ctx);

  T visitSimpleIdentifierType(SimpleIdentifierTypeContext ctx);

  T visitNamespacedIdentifierType(NamespacedIdentifierTypeContext ctx);

  T visitTupleType(TupleTypeContext ctx);

  T visitFunctionType(FunctionTypeContext ctx);

  T visitSimpleIdentifier(SimpleIdentifierContext ctx);

  T visitNamespacedIdentifier(NamespacedIdentifierContext ctx);

  T visitNumberLiteral(NumberLiteralContext ctx);

  T visitStringLiteral(StringLiteralContext ctx);

  T visitPrefixExpression(PrefixExpressionContext ctx);

  T visitPostfixExpression(PostfixExpressionContext ctx);

  T visitAssignmentExpression(AssignmentExpressionContext ctx);

  T visitBinaryExpression(BinaryExpressionContext ctx);

  T visitConditionalExpression(ConditionalExpressionContext ctx);

  T visitTupleExpression(TupleExpressionContext ctx);

  T visitCallExpression(CallExpressionContext ctx);

  T visitMemberExpression(MemberExpressionContext ctx);

  T visitBlock(BlockContext ctx);

  T visitExpressionStatement(ExpressionStatementContext ctx);

  T visitReturnStatement(ReturnStatementContext ctx);

  T visitVariableDeclarationStatement(VariableDeclarationStatementContext ctx);

  T visitVariableDeclaration(VariableDeclarationContext ctx);

  T visitFunctionSignature(FunctionSignatureContext ctx);

  T visitBlockFunctionBody(BlockFunctionBodyContext ctx);

  T visitLambdaFunctionBody(LambdaFunctionBodyContext ctx);

  T visitParameterList(ParameterListContext ctx);

  T visitParameter(ParameterContext ctx);

  T visitClassDeclaration(ClassDeclarationContext ctx);

  T visitArrayLiteral(ArrayLiteralContext ctx);

  T visitObjectLiteral(ObjectLiteralContext ctx);

  T visitRangeExpression(RangeExpressionContext ctx);

  T visitStructType(StructTypeContext ctx);

  T visitStructField(StructFieldContext ctx);
}
