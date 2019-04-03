package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboFunction;

public class BananaPassBlockCompiler {
    private final BananaPass bananaPass;
    private final BonoboFunction bonoboFunction;
    private final BananaFunction bananaFunction;
    private final BananaBlock block;

    public BananaPassBlockCompiler(BananaPass bananaPass, BonoboFunction bonoboFunction, BananaFunction bananaFunction, BananaBlock block) {
        this.bananaPass = bananaPass;
        this.bonoboFunction = bonoboFunction;
        this.bananaFunction = bananaFunction;
        this.block = block;
    }

    void run() {
    }
}
