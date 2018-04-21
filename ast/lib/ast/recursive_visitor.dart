part of bonobo.src.ast;

/// A [BonoboAstVisitor] that recursively visits every node in a given source tree.
///
/// Overridden methods should be sure to either call `super` or to manually visit child nodes
/// or nodes like [BlockContext].
class BonoboRecursiveAstVisitor<T> extends BonoboAstVisitor<T> {
  T visitFunctionBody(FunctionBodyContext ctx) => ctx?.accept(this);

  T visitStatement(StatementContext ctx) => ctx?.accept(this);

  T visitExpression(ExpressionContext ctx) => ctx?.accept(this);

  T visitType(TypeContext ctx) => ctx?.accept(this);

  @override
  T visitCompilationUnit(CompilationUnitContext ctx) {
    if (ctx == null) return null;
    ctx..typedefs.forEach(visitTypedef)..functions.forEach(visitFunction);
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

  @override
  T visitBlock(BlockContext ctx) {
    if (ctx == null) return null;
    ctx.statements.forEach(visitStatement);
    return null;
  }

  @override
  T visitLambdaFunctionBody(LambdaFunctionBodyContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitSimpleIdentifierType(SimpleIdentifierTypeContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.identifier);
    return null;
  }

  @override
  T visitNamespacedIdentifierType(NamespacedIdentifierTypeContext ctx) {
    if (ctx == null) return null;
    visitNamespacedIdentifier(ctx.identifier);
    return null;
  }

  @override
  T visitParenthesizedType(ParenthesizedTypeContext ctx) {
    if (ctx == null) return null;
    visitType(ctx.innermost);
    return null;
  }

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

  @override
  T visitVariableDeclarationStatement(VariableDeclarationStatementContext ctx) {
    if (ctx == null) return null;
    ctx.declarations.forEach(visitVariableDeclaration);
    ctx.context.forEach(visitStatement);
    return null;
  }

  @override
  T visitVariableDeclaration(VariableDeclarationContext ctx) {
    if (ctx == null) return null;
    visitSimpleIdentifier(ctx.name);
    visitExpression(ctx.expression);
    return null;
  }

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
  T visitPrefixExpression(PrefixExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitPostfixExpression(PostfixExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitPrintExpression(PrintExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitParenthesizedExpression(ParenthesizedExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.expression);
    return null;
  }

  @override
  T visitMemberExpression(MemberExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.target);
    visitSimpleIdentifier(ctx.identifier);
    return null;
  }

  @override
  T visitNamespacedIdentifier(NamespacedIdentifierContext ctx) {
    if (ctx == null) return null;
    ctx.namespaces.forEach(visitSimpleIdentifier);
    visitSimpleIdentifier(ctx.symbol);
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
  T visitTupleExpression(TupleExpressionContext ctx) {
    if (ctx == null) return null;
    ctx.expressions.forEach(visitExpression);
    return null;
  }

  @override
  T visitAssignmentExpression(AssignmentExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.left);
    visitExpression(ctx.right);
    return null;
  }

  @override
  T visitBinaryExpression(BinaryExpressionContext ctx) {
    if (ctx == null) return null;
    visitExpression(ctx.left);
    visitExpression(ctx.right);
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
  T visitSimpleIdentifier(SimpleIdentifierContext ctx) => null;

  @override
  T visitNumberLiteral(NumberLiteralContext ctx) => null;

  @override
  T visitStringLiteral(StringLiteralContext ctx) => null;
}
