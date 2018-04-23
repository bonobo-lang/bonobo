part of bonobo.src.ast;

/// A visitor that produces some representation of a Bonobo source tree.
abstract class BonoboAstVisitor<T> {
  T visit(AstNode node) => node.accept(this);

  T visitCompilationUnit(CompilationUnitContext ctx);

  T visitTypedef(TypedefContext ctx);

  // Expression

  T visitSimpleIdentifier(SimpleIdentifierContext ctx);

  T visitNamespacedIdentifier(NamespacedIdentifierContext ctx);

  T visitNumberLiteral(NumberLiteralContext ctx);

  T visitStringLiteral(StringLiteralContext ctx);

  T visitPrefixExpression(PrefixExpressionContext ctx);

  T visitBinaryExpression(BinaryExpressionContext ctx);

  T visitIdentifierChainExpression(IdentifierChainExpressionContext ctx);

  T visitCallExpression(CallExpressionContext ctx);

  T visitPostfixExpression(PostfixExpressionContext ctx);

  T visitConditionalExpression(ConditionalExpressionContext ctx);

  //T visitArrayLiteral(ArrayLiteralContext ctx);

  T visitMapLiteral(MapLiteralContext ctx);

  T visitRangeLiteral(RangeLiteralContext ctx);

  // Types

  T visitType(TypeContext ctx);

  T visitNamedType(NamedTypeContext ctx);

  T visitFunctionType(FunctionTypeContext ctx);

  T visitStructType(StructTypeContext ctx);

  T visitStructField(StructFieldContext ctx);

  T visitTupleType(TupleTypeContext ctx);

  //T visitAnonymousType(AnonymousTypeContext ctx);

  // Function

  T visitFunction(FunctionContext ctx);

  T visitFunctionSignature(FunctionSignatureContext ctx);

  T visitParameterList(ParameterListContext ctx);

  T visitParameter(ParameterContext ctx);

  T visitBlockFunctionBody(BlockFunctionBodyContext ctx);

  T visitLambdaFunctionBody(ExpressionFunctionBodyContext ctx);

  // Statements

  T visitExpressionStatement(ExpressionStatementContext ctx);

  T visitReturnStatement(ReturnStatementContext ctx);

  T visitVariableDeclarationStatement(VariableDeclarationStatementContext ctx);

  T visitVariableDeclaration(VariableDeclarationContext ctx);

  T visitAssignStatement(AssignStatementContext ctx);

  T visitForStatement(ForStatementContext ctx);

  T visitBlock(BlockContext ctx);

  // Type declaration

  /*
  T visitTypeDeclaration(TypeDeclarationContext ctx);

  T visitEnumDeclaration(EnumDeclarationContext ctx);*/

  T visitEnumValue(EnumValueContext ctx);

  T visitTupleExpression(TupleExpressionContext ctx);

  T visitMemberExpression(MemberExpressionContext ctx);

  T visitEnumType(EnumTypeContext ctx);

  T visitParenthesizedExpression(ParenthesizedExpressionContext ctx);
}
