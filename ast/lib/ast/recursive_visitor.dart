part of bonobo.src.ast;

/// A [BonoboAstVisitor] that recursively visits every node in a given source tree.
///
/// Overridden methods should be sure to either call `super` or to manually visit child nodes
/// or nodes like [BlockContext].
class BonoboRecursiveAstVisitor<T> extends BonoboAstVisitor<T> {
  @override
  T visitUnit(UnitContext ctx) {
    if (ctx == null) return null;
    ctx
      ..functions.forEach(visitFunction)
      ..classes.forEach(visitTypeDeclaration);
    return null;
  }

  // Expression

  T visitExpression(ExpressionContext ctx) => ctx?.accept(this);

  @override
  T visitSimpleIdentifier(SimpleIdentifierContext ctx) => null;

  @override
  T visitNamespacedIdentifier(NamespacedIdentifierContext ctx) {
    if (ctx == null) return null;
    ctx.namespaces.forEach(visitSimpleIdentifier);
    visitSimpleIdentifier(ctx.symbol);
    return null;
  }

  @override
  T visitNumberLiteral(NumberLiteralContext ctx) => null;

  @override
  T visitStringLiteral(StringLiteralContext ctx) => null;

  @override
  T visitPrefixExpression(PrefixExpressionCtx ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  T visitBinaryExpression(BinaryExpressionCtx ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.left);
    visitExpression(ctx.right);
    return null;
  }

  T visitIdentifierChainExpression(IdentifierChainExpressionCtx ctx) {
    if (ctx == null) return null;
    // TODO visit identifier
    // TODO follow chain?
    return null;
  }

  T visitTupleLiteral(TupleLiteralCtx ctx) {
    if (ctx == null) return null;
    ctx.items.forEach(visitExpression);
    return null;
  }

  @override
  T visitArrayLiteral(ArrayLiteralCtx ctx) {
    if (ctx == null) return null;
    ctx.items.forEach(visitExpression);
    return null;
  }

  T visitMapLiteral(MapLiteralCtx ctx) {
    if (ctx == null) return null;
    // TODO iterate over key:value pairs
    return null;
  }

  @override
  T visitRangeLiteral(RangeLiteralCtx ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.start);
    visitExpression(ctx.end);
    visitExpression(ctx.step);
    return null;
  }

  // Function

  @override
  T visitFunction(FunctionContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitFunctionSignature(ctx.signature);
    visitFunctionBody(ctx.body);
    return null;
  }

  @override
  T visitFunctionSignature(FunctionSignatureContext ctx) {
    if (ctx == null) return null;
    visitParameterList(ctx.parameterList);
    visitType(ctx.returnType);
    return null;
  }

  @override
  T visitParameterList(ParameterListContext ctx) {
    if (ctx == null) return null;
    ctx.parameters.forEach(visitParameter);
    return null;
  }

  @override
  T visitParameter(ParameterContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitType(ctx.type);
    return null;
  }

  @override
  T visitBlockFunctionBody(BlockFunctionBodyContext ctx) {
    if (ctx == null) return null;
    visitBlock(ctx.block);
    return null;
  }

  T visitFunctionBody(FunctionBodyContext ctx) => ctx?.accept(this);

  @override
  T visitSameLineFunctionBody(SameLineFunctionBodyContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  // Statements

  T visitStatement(StatementContext ctx) => ctx?.accept(this);

  @override
  T visitExpressionStatement(ExpressionStatementContext ctx) {
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitReturnStatement(ReturnStatementContext ctx) {
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitVariableDeclarationStatement(VarDeclarationStatementContext ctx) {
    if (ctx == null) return null;
    ctx.declarations.forEach(visitVariableDeclaration);
    return null;
  }

  @override
  T visitVariableDeclaration(VarDeclarationContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitExpression(ctx.initializer);
    return null;
  }

  T visitAssignStatement(AssignStatementCtx ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.left);
    visitExpression(ctx.right);
    return null;
  }

  T visitForStatement(ForStatementCtx ctx) {
    if (ctx == null) return null;
    // TODO
    return null;
  }

  @override
  T visitBlock(BlockContext ctx) {
    if (ctx == null) return null;
    ctx.statements.forEach(visitStatement);
    return null;
  }

  // Types

  T visitType(TypeContext ctx) => ctx?.accept(this);

  T visitNamedType(NamedTypeContext ctx) {
    if (ctx == null) return null;
    ctx.namespaces.forEach(visitSimpleIdentifier);
    visitSimpleIdentifier(ctx.symbol);
    ctx.generics.forEach(visitType);
    return null;
  }

  T visitFunctionType(FunctionTypeCtx ctx) {
    if (ctx == null) return null;
    visitFunctionSignature(ctx.signature);
    return null;
  }

  T visitAnonymousType(AnonymousTypeCtx ctx) {
    if (ctx == null) return null;
    visitVariableDeclarationStatement(ctx.fields);
    return null;
  }

  // Classes

  @override
  T visitTypeDeclaration(TypeDeclarationContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    ctx.fields.forEach(visitVariableDeclarationStatement);
    ctx.methods.forEach(visitFunction);
    return null;
  }

  /* TODO
  @override
  T visitTupleType(TupleTypeContext ctx) {
    if (ctx == null) return null;
    ctx.items.forEach(visitType);
    return null;
  }

  @override
  T visitFunctionType(FunctionTypeContext ctx) {
    if (ctx == null) return null;
    ctx.parameters.forEach(visitType);
    visitType(ctx.returnType);
    return null;
  }
  */

  /* TODO
  @override
  T visitEnumValue(EnumValueContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitNumberLiteral(ctx.index);
    return null;
  }

  @override
  T visitEnumType(EnumTypeContext ctx) {
    if (ctx == null) return null;
    ctx.values.forEach(visitEnumValue);
    return null;
  }
  */
}
