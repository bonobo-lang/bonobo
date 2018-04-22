part of bonobo.src.ast;

/// A visitor that produces some representation of a Bonobo source tree.
abstract class BonoboAstVisitor<T> {
  T visit(AstNode node) => node.accept(this);

  T visitUnit(UnitContext ctx);

  // Expression

  T visitSimpleIdentifier(SimpleIdentifierContext ctx);

  T visitNamespacedIdentifier(NamespacedIdentifierContext ctx);

  T visitNumberLiteral(NumberLiteralContext ctx);

  T visitStringLiteral(StringLiteralContext ctx);

  T visitPrefixExpression(PrefixExpressionCtx ctx);

  T visitBinaryExpression(BinaryExpressionCtx ctx);

  T visitIdentifierChainExpression(IdentifierChainExpressionCtx ctx);

  T visitTupleLiteral(TupleLiteralCtx ctx);

  T visitArrayLiteral(ArrayLiteralCtx ctx);

  T visitMapLiteral(MapLiteralCtx ctx);

  T visitRangeLiteral(RangeLiteralCtx ctx);

  // Types

  T visitType(TypeContext ctx);

  T visitNamedType(NamedTypeContext ctx);

  T visitFunctionType(FunctionTypeCtx ctx);

  T visitAnonymousType(AnonymousTypeCtx ctx);

  // Function

  T visitFunction(FunctionContext ctx);

  T visitFunctionSignature(FunctionSignatureContext ctx);

  T visitParameterList(ParameterListContext ctx);

  T visitParameter(ParameterContext ctx);

  T visitBlockFunctionBody(BlockFunctionBodyContext ctx);

  T visitSameLineFunctionBody(SameLineFunctionBodyContext ctx);

  // Statements

  T visitExpressionStatement(ExpressionStatementContext ctx);

  T visitReturnStatement(ReturnStatementContext ctx);

  T visitVariableDeclarationStatement(VarDeclarationStatementContext ctx);

  T visitVariableDeclaration(VarDeclarationContext ctx);

  T visitAssignStatement(AssignStatementCtx ctx);

  T visitForStatement(ForStatementCtx ctx);

  T visitBlock(BlockContext ctx);

  // Types

  T visitTypeDeclaration(TypeDeclarationContext ctx);

  /* TODO
  T visitTupleType(TupleTypeContext ctx);

  T visitFunctionType(FunctionTypeContext ctx);
  */

  /* TODO

  T visitStructType(StructTypeContext ctx);

  T visitStructField(StructFieldContext ctx);
  */

  /* TODO
  T visitEnumType(EnumTypeContext ctx);

  T visitEnumValue(EnumValueContext ctx);
  */
}
