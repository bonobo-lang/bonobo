package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.*;

public class BananaPass {
    private final BonoboAnalyzer analyzer;
    private final BonoboModule module;
    private final BananaModule bananaModule;

    public BananaPass(BonoboAnalyzer analyzer, BonoboModule module) {
        this.analyzer = analyzer;
        this.module = module;
        bananaModule = new BananaModule(module.getName());
    }

    public BananaModule getBananaModule() {
        return bananaModule;
    }

    public BonoboAnalyzer getAnalyzer() {
        return analyzer;
    }

    public BonoboModule getModule() {
        return module;
    }

    public void run() {
        // All top-level functions are mapped to Banana functions.
        for (BonoboSymbol sym : module.getScope().getSymbols()) {
            if (sym.isValue()) {
                BonoboValue value = sym.getValue();

                if (value instanceof BonoboFunction) {
                    compileTopLevelFunction((BonoboFunction) value);
                }
            }
        }
    }

    public void compileTopLevelFunction(BonoboFunction fn) {
        // Create a new function, and then just compile all of the statements into
        // SSA form.
        BonoboScope scope = fn.getBody().getScope();
        BananaTypeCompiler typeCompiler = new BananaTypeCompiler(this, scope);
        BananaType returnType = fn.getBody().getReturnType().accept(typeCompiler);
        BananaFunction bananaFunction = new BananaFunction(fn.getName(), returnType);
        bananaModule.getFunctions().add(bananaFunction);
        BananaBlockCompiler blockCompiler = new BananaBlockCompiler(this, fn, bananaFunction, bananaFunction.getEntryBlock());
        blockCompiler.run();
    }
}
