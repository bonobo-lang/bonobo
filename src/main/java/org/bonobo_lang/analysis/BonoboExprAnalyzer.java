package org.bonobo_lang.analysis;
import org.bonobo_lang.frontend.BonoboParser;
import org.bonobo_lang.frontend.BonoboBaseVisitor;

public class BonoboExprAnalyzer extends BonoboBaseVisitor<BonoboValue> {
    private final BonoboAnalyzer analyzer;
    private final BonoboFunctionAnalyzer functionAnalyzer;
    private final BonoboScope scope;

    public BonoboExprAnalyzer(BonoboAnalyzer analyzer, BonoboFunctionAnalyzer functionAnalyzer, BonoboScope scope) {
        this.analyzer = analyzer;
        this.functionAnalyzer = functionAnalyzer;
        this.scope = scope;
    }

    @Override
    public Object visitIntExpr(BonoboParser.IntExprContext ctx) {
        return super.visitIntExpr(ctx);
    }
}
