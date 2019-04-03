package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

public class BonoboFunctionAnalyzer {
    private BonoboAnalyzer analyzer;
    private BonoboModule module;

    public BonoboFunctionAnalyzer(BonoboAnalyzer analyzer, BonoboModule module) {
        this.analyzer = analyzer;
        this.module = module;
    }

    public void run() {
        // Analyze all top-level functions.
        for (BonoboSymbol sym : module.getScope().getSymbols()) {
            if (sym.isValue()) {
                BonoboValue value = sym.getValue();

                if (value instanceof BonoboFunction) {
                    analyzeTopLevelFunction((BonoboFunction) value);
                }
            }
        }
    }

    public void analyzeTopLevelFunction(BonoboFunction fn) {
        // Firstly, we want to analyze all of its parameters.
        // TODO: Params

        // Next, we want to analyze its block, and
        // determine its return type, if none has been declared.
    }

    public BonoboBlock analyzeBlock(BonoboScope scope, BonoboParser.BlockContext ctx) {
        // TODO: Dead code warnings
        BonoboBlock block = new BonoboBlock(scope);

        if (ctx instanceof BonoboParser.LambdaBlockContext) {
            BonoboStatementAnalyzer statementAnalyzer = new BonoboStatementAnalyzer(analyzer, this, scope);
            BonoboBlockState state = statementAnalyzer.analyzeExpr(((BonoboParser.LambdaBlockContext) ctx).expr());
            block.getBody().add(state);
        } else if (ctx instanceof BonoboParser.SingleStatementBlockContext) {
            // TODO: Single statement
        } else if (ctx instanceof BonoboParser.BasicBlockContext) {
            for (BonoboParser.StmtContext stmt : ((BonoboParser.BasicBlockContext) ctx).stmt()) {
                BonoboBlockState state = analyzeStatement(scope.createChild(), stmt);

                if (state == null) {
                    // TODO: What if state is null?
                } else {
                    block.getBody().add(state);
                    scope = state.getScope();
                }
            }
        }

        return block;
    }

    public BonoboBlockState analyzeStatement(BonoboScope scope, BonoboParser.StmtContext ctx) {
        BonoboStatementAnalyzer statementAnalyzer = new BonoboStatementAnalyzer(analyzer, this, scope);
        return ctx.accept(statementAnalyzer);
    }
}
