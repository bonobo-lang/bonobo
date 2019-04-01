package org.bonobo_lang.analysis;

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
}
