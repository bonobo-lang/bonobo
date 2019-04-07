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

    public BonoboValue visitIdExpr(BonoboParser.IdExprContext ctx) {
        String name = ctx.getText();
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
        BonoboSymbol symbol = scope.resolve(name);

        if (symbol == null) {
            analyzer.getErrors().add(new BonoboError(
                    BonoboError.Severity.error, location,
                    String.format("The name \"%s\" does not exist in this scope.", name)));
            return null;
        } else if (symbol.isType()) {
            analyzer.getErrors().add(new BonoboError(
                    BonoboError.Severity.error, location,
                    String.format("%s resolves a type, and cannot be used as a value.", name)));
            return null;
        } else {
            BonoboType type = symbol.getValue().getType();
            return new BonoboVariableGet(location, type, symbol);
        }
    }


    public BonoboValue visitIntExpr(BonoboParser.IntExprContext ctx) {
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
        Integer value = Integer.parseInt(ctx.getText());
        BonoboType intType = analyzer.getCoreModule().getInt64Type();
        return new BonoboConstant(location, intType, value);
    }


    public BonoboValue visitHexExpr(BonoboParser.HexExprContext ctx) {
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
        Integer value = Integer.parseInt(ctx.getText().substring(2), 16);
        BonoboType intType = analyzer.getCoreModule().getInt64Type();
        return new BonoboConstant(location, intType, value);
    }
}
