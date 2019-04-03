package org.bonobo_lang.analysis;
import org.bonobo_lang.frontend.BonoboParser;
import org.bonobo_lang.frontend.BonoboBaseVisitor;

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

    public BonoboBlockState analyzeExpr(SourceLocation location, BonoboParser.ExprContext ctx) {
        BonoboExprAnalyzer exprAnalyzer = new BonoboExprAnalyzer(analyzer, module, functionAnalyzer, scope);
        BonoboValue value = ctx.accept(exprAnalyzer);

        if (value == null) {
            // TODO: What if this is null?
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
        return analyzeExpr(location, ctx.expr());
    }
}
