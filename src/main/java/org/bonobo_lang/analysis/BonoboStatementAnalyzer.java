package org.bonobo_lang.analysis;
import org.bonobo_lang.frontend.BonoboParser;
import org.bonobo_lang.frontend.BonoboBaseVisitor;

public class BonoboStatementAnalyzer extends BonoboBaseVisitor<BonoboBlockState> {
    private final BonoboAnalyzer analyzer;
    private final BonoboFunctionAnalyzer functionAnalyzer;
    private final BonoboScope scope;

    public BonoboStatementAnalyzer(BonoboAnalyzer analyzer, BonoboFunctionAnalyzer functionAnalyzer, BonoboScope scope) {
        this.analyzer = analyzer;
        this.functionAnalyzer = functionAnalyzer;
        this.scope = scope;
    }

    public BonoboBlockState analyzeExpr(BonoboParser.ExprContext ctx) {
        // TODO:
        return null;
    }

    @Override
    public BonoboBlockState visitReturnStmt(BonoboParser.ReturnStmtContext ctx) {
        return analyzeExpr(ctx.expr());
    }
}
