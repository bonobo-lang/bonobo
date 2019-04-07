package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboBaseVisitor;
import org.bonobo_lang.frontend.BonoboParser;

public class BonoboStatementAnalyzer extends BonoboBaseVisitor<BonoboBlockState> {
    private final BonoboAnalyzer analyzer;
    private final BonoboModule module;
    private final BonoboFunctionAnalyzer functionAnalyzer;
    private final BonoboScope scope;

    public BonoboStatementAnalyzer(BonoboAnalyzer analyzer, BonoboModule module, BonoboFunctionAnalyzer functionAnalyzer, BonoboScope scope) {
        this.analyzer = analyzer;
        this.module = module;
        this.functionAnalyzer = functionAnalyzer;
        this.scope = scope;
    }

    public BonoboValue analyzeExpr(SourceLocation location, BonoboParser.ExprContext ctx) {
        BonoboExprAnalyzer exprAnalyzer = new BonoboExprAnalyzer(analyzer, module, functionAnalyzer, scope);
        return ctx.accept(exprAnalyzer);
    }

    public BonoboBlockState analyzeReturn(SourceLocation location, BonoboParser.ExprContext ctx) {
        BonoboValue value = analyzeExpr(location, ctx);

        if (value == null) {
            analyzer.getErrors().add(new BonoboError(
                    BonoboError.Severity.error,
                    location,
                    "Evaluation of the returned expression produced an error."
            ));
            return null;
        } else {
            BonoboBlockState state = new BonoboBlockState(scope);
            BonoboReturnStatement stmt = new BonoboReturnStatement(location, scope, value);
            state.setStatement(stmt);
            state.setReturnValue(value);
            return state;
        }
    }

    @Override
    public BonoboBlockState visitReturnStmt(BonoboParser.ReturnStmtContext ctx) {
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
        return analyzeReturn(location, ctx.expr());
    }

    @Override
    public BonoboBlockState visitVarDeclStmt(BonoboParser.VarDeclStmtContext ctx) {
        // Firstly, we analyze the expression.
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
        BonoboExprAnalyzer exprAnalyzer = new BonoboExprAnalyzer(analyzer, module, functionAnalyzer, scope);
        String name = ctx.ID().getText();
        BonoboValue value = ctx.accept(exprAnalyzer);

        if (value == null) {
            analyzer.getErrors().add(new BonoboError(
                    BonoboError.Severity.error,
                    location,
                    String.format(
                            "Evaluation of this expression produced an error, so it cannot be assigned to %s.", name)
            ));
            return null;
        }

        // If there is an explicit type, we want to resolve it, and then
        // change `value` accordingly.
        // TODO: Handle explicit type

        // Add the declared variable to the scope.
        try {
            BonoboSymbol symbol = scope.create(location, name, value);
            BonoboBlockState state = new BonoboBlockState(scope);
            state.setStatement(new BonoboVariableDeclarationStatement(scope, symbol));
            return state;
        } catch (IllegalStateException exc) {
            analyzer.getErrors().add(new BonoboError(BonoboError.Severity.error, location, exc.getMessage()));
            return null;
        }
    }
}
