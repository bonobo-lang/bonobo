package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboAnalyzer;
import org.bonobo_lang.analysis.BonoboModule;

public class BananaPass {
    private final BonoboAnalyzer analyzer;
    private final BonoboModule module;
    private final BananaModule bananaModule;

    public BananaPass(BonoboAnalyzer analyzer, BonoboModule module) {
        this.analyzer = analyzer;
        this.module = module;
        bananaModule = new BananaModule(module.getName());
    }
}
