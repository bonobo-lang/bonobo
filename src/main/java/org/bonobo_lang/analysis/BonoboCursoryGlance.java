package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

/**
 * The first pass over a Bonobo AST is solely to collect names of functions,
 * classes, and other types in a module.
 * <p>
 * It does not perform in-depth analysis, i.e. control-flow analysis, etc.
 * Circular imports are handled here.
 */
public class BonoboCursoryGlance {
    private final BonoboAnalyzer analyzer;
    private final BonoboModule module;

    public BonoboCursoryGlance(BonoboAnalyzer analyzer, BonoboModule module) {
        this.analyzer = analyzer;
        this.module = module;
    }

    public BonoboAnalyzer getAnalyzer() {
        return analyzer;
    }

    public BonoboModule getModule() {
        return module;
    }

    public void run() {
        // Walk through all the top-level declarations.
        for (BonoboParser.TopLevelContext ctx : module.getCtx().topLevel()) {
            if (ctx.fnDecl() != null) {
                visitFnDecl(ctx.fnDecl());
            }
        }
    }

    private void visitFnDecl(BonoboParser.FnDeclContext ctx) {
        String name = ctx.ID().getText();
        BonoboFunction fn = new BonoboFunction(module, name);
        SourceLocation location = new SourceLocation(module.getSourceUrl(), ctx);

        try {
            fn.setDeclaration(ctx);
            module.getScope().create(location, name, fn);
        } catch (IllegalStateException exc) {
            analyzer.getErrors().add(new BonoboError(BonoboError.Severity.error, location, exc.getMessage()));
        }
    }
}