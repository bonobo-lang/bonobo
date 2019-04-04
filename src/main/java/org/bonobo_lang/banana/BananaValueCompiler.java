package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboBlockState;
import org.bonobo_lang.analysis.BonoboConstant;
import org.bonobo_lang.analysis.BonoboIntegerType;
import org.bonobo_lang.analysis.BonoboValueVisitor;

public class BananaValueCompiler implements BonoboValueVisitor<BananaValue> {
    private final BananaBlockCompiler blockCompiler;
    private final BonoboBlockState state;

    public BananaValueCompiler(BananaBlockCompiler blockCompiler, BonoboBlockState state) {
        this.blockCompiler = blockCompiler;
        this.state = state;
    }

    @Override
    public BananaValue visitConstant(BonoboConstant ctx) {
        if (ctx.getType() instanceof BonoboIntegerType) {
            BananaType type = new BananaIntegerType((BonoboIntegerType) ctx.getType());
            return new BananaConstant(type, ctx);
        }

        // TODO: Other constants
        return null;
    }
}
