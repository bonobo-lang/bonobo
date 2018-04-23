part of bonobo.src.ast;

/// A [BonoboAstVisitor] that recursively visits every node in a given source tree.
///
/// Overridden methods should be sure to either call `super` or to manually visit child nodes
/// or nodes like [BlockContext].
class BonoboRecursiveAstVisitor<T> extends BonoboAstVisitor<T> {
  @override
  T visitCompilationUnit(CompilationUnitContext ctx) {
    if (ctx == null) return null;
    ctx..functions.forEach(visitFunction)..typedefs.forEach(visitTypedef);
    //..classes.forEach(visitTypeDeclaration);
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
  T visitPrefixExpression(PrefixExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  T visitBinaryExpression(BinaryExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.left);
    visitExpression(ctx.right);
    return null;
  }

  T visitIdentifierChainExpression(IdentifierChainExpressionContext ctx) {
    if (ctx == null) return null;
    // TODO visit identifier
    // TODO follow chain?
    return null;
  }

  /*
  T visitTupleLiteral(ObjectLiteralContext ctx) {
    if (ctx == null) return null;
    ctx.items.forEach(visitExpression);
    return null;
  }

  @override
  T visitArrayLiteral(ArrayLiteralContext ctx) {
    if (ctx == null) return null;
    ctx.items.forEach(visitExpression);
    return null;
  }*/

  T visitMapLiteral(MapLiteralContext ctx) {
    if (ctx == null) return null;
    // TODO iterate over key:value pairs
    return null;
  }

  @override
  T visitRangeLiteral(RangeLiteralContext ctx) {
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
  T visitLambdaFunctionBody(ExpressionFunctionBodyContext ctx) {
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
  T visitVariableDeclarationStatement(VariableDeclarationStatementContext ctx) {
    if (ctx == null) return null;
    ctx.declarations.forEach(visitVariableDeclaration);
    return null;
  }

  @override
  T visitVariableDeclaration(VariableDeclarationContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitExpression(ctx.expression);
    return null;
  }

  T visitAssignStatement(AssignStatementContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.left);
    visitExpression(ctx.right);
    return null;
  }

  T visitForStatement(ForStatementContext ctx) {
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
    // TODO: Add visitIdentifier stub
    ctx.identifier.accept(this);
    ctx.generics.forEach(visitType);
    return null;
  }

  T visitFunctionType(FunctionTypeContext ctx) {
    if (ctx == null) return null;

    return null;
  }

  /*
  T visitAnonymousType(AnonymousTypeContext ctx) {
    if (ctx == null) return null;
    visitVariableDeclarationStatement(ctx.fields);
    return null;
  }*/

  // Classes

  /*
  @override
  T visitTypeDeclaration(TypeDeclarationContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    ctx.fields.forEach(visitVariableDeclarationStatement);
    ctx.methods.forEach(visitFunction);
    return null;
  }*/

  @override
  T visitEnumValue(EnumValueContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitNumberLiteral(ctx.index);
    return null;
  }

  @override
  T visitTupleExpression(TupleExpressionContext ctx) {
    if (ctx == null) return null;
    ctx.expressions.forEach(visitExpression);
    return null;
  }

  @override
  T visitTupleType(TupleTypeContext ctx) {
    if (ctx == null) return null;
    ctx.items.forEach(visitType);
    return null;
  }

  @override
  T visitStructField(StructFieldContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitType(ctx.type);
    return null;
  }

  @override
  T visitStructType(StructTypeContext ctx) {
    if (ctx == null) return null;
    ctx.fields.forEach(visitStructField);
    return null;
  }

  @override
  T visitConditionalExpression(ConditionalExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.condition);
    visitExpression(ctx.ifTrue);
    visitExpression(ctx.ifFalse);
    return null;
  }

  @override
  T visitPostfixExpression(PostfixExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitCallExpression(CallExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.target);
    visitTupleExpression(ctx.arguments);
    return null;
  }

  @override
  T visitTypedef(TypedefContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitType(ctx.type);
    return null;
  }

  @override
  T visitEnumType(EnumTypeContext ctx) {
    if (ctx == null) return null;
    return null;
  }

  @override
  T visitMemberExpression(MemberExpressionContext ctx) {
    if (ctx == null) return null;
    return null;
  }

  @override
  T visitParenthesizedExpression(ParenthesizedExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.innermost);
    return null;
  }

/*
  @override
  T visitEnumDeclaration(EnumDeclarationContext ctx) {
    if (ctx == null) return null;
    ctx.values.forEach(visitEnumValue);
    return null;
  }*/
}
