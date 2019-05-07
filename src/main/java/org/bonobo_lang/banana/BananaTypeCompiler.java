package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboIntegerType;
import org.bonobo_lang.analysis.BonoboScope;
import org.bonobo_lang.analysis.BonoboTypeVisitor;
import org.bonobo_lang.analysis.BonoboVoidType;

public class BananaTypeCompiler implements BonoboTypeVisitor<BananaType> {
    private final BananaPass bananaPass;
    private final BonoboScope scope;

    public BananaTypeCompiler(BananaPass bananaPass, BonoboScope scope) {
        this.bananaPass = bananaPass;
        this.scope = scope;
    }

    @Override
    public BananaType visitIntegerType(BonoboIntegerType ctx) {
        return new BananaIntegerType(ctx);
    }

    @Override
    public BananaType visitVoidType(BonoboVoidType ctx) {
        return new BananaVoidType();
    }
}
