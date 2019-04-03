package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboBaseVisitor;
import org.bonobo_lang.frontend.BonoboParser;

public class BonoboExprAnalyzer extends BonoboBaseVisitor<BonoboValue> {
    private final BonoboAnalyzer analyzer;
    private final BonoboModule module;
    private final BonoboFunctionAnalyzer functionAnalyzer;
    private final BonoboScope scope;

    public BonoboExprAnalyzer(BonoboAnalyzer analyzer, BonoboModule module, BonoboFunctionAnalyzer functionAnalyzer, BonoboScope scope) {
        this.analyzer = analyzer;
        this.module = module;
        this.functionAnalyzer = functionAnalyzer;
        this.scope = scope;
    }

    @Override
    public BonoboValue visitIntExpr(BonoboParser.IntExprContext ctx) {
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
        Integer value = Integer.parseInt(ctx.getText());
        BonoboType intType = analyzer.getCoreModule().getInt64Type();
        return new BonoboConstant(location, intType, value);
    }

    @Override
    public BonoboValue visitHexExpr(BonoboParser.HexExprContext ctx) {
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
        Integer value = Integer.parseInt(ctx.getText().substring(2), 16);
        BonoboType intType = analyzer.getCoreModule().getInt64Type();
        return new BonoboConstant(location, intType, value);
    }
}
