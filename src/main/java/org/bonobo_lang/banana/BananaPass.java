package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.*;

import java.util.ArrayList;
import java.util.List;

public class BananaPass {
    private final List<BananaVariable> variables = new ArrayList<>();
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

    public List<BananaVariable> getVariables() {
        return variables;
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

    public BananaVariable createVariable(String name, BananaType type) {
        int i = -1;

        while (true) {
            String outName = i == -1 ? name : String.format("%s%d", name, i);
            i++;

            boolean exists = false;
            for (BananaVariable variable : variables) {
                if (variable.getName().equals(outName)) {
                    exists = true;
                    break;
                }
            }

            if (!exists) {
                BananaVariable variable = new BananaVariable(outName, type);
                variables.add(variable);
                return variable;
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
