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
                    analyzeTopLevelFunction((BonoboFunction) value, ((BonoboFunction) value).getBlock());
                }
            }
        }
    }

    public void analyzeTopLevelFunction(BonoboFunction fn, BonoboParser.BlockContext ctx) {
        // Firstly, we want to analyzeCursory all of its parameters.
        // TODO: Params

        // Next, we want to analyzeCursory its block, and
        // determine its return type, if none has been declared.
        BonoboBlock block = analyzeBlock(fn.getScope().createChild(), ctx);
        fn.setBody(block);
    }

    public BonoboBlock analyzeBlock(BonoboScope scope, BonoboParser.BlockContext ctx) {
        // TODO: Dead code warnings
        BonoboBlock block = new BonoboBlock(scope);

        if (ctx instanceof BonoboParser.LambdaBlockContext) {
            BonoboStatementAnalyzer statementAnalyzer = new BonoboStatementAnalyzer(analyzer, module, this, scope);
            SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);
            BonoboBlockState state = statementAnalyzer.analyzeExpr(location, ((BonoboParser.LambdaBlockContext) ctx).expr());
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

        // Set the block's return type.
        for (BonoboBlockState state : block.getBody()) {
            if (state.getReturnValue() != null) {
                block.setReturnType(state.getReturnType());
            }
        }

        return block;
    }

    public BonoboBlockState analyzeStatement(BonoboScope scope, BonoboParser.StmtContext ctx) {
        BonoboStatementAnalyzer statementAnalyzer = new BonoboStatementAnalyzer(analyzer, module, this, scope);
        return ctx.accept(statementAnalyzer);
    }
}
