package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.*;

public class BananaPassStatementCompiler implements BonoboStatementVisitor {
    private final BananaPassBlockCompiler blockCompiler;
    private final BonoboBlockState state;

    public BananaPassStatementCompiler(BananaPassBlockCompiler blockCompiler, BonoboBlockState state) {
        this.blockCompiler = blockCompiler;
        this.state = state;
    }

    @Override
    public Object visitReturnStatement(BonoboReturnStatement ctx) {
        // Check if this is a Bonobo constant. If so, we can have a specific return.
        if (ctx.getReturnValue() instanceof BonoboConstant) {
            BonoboConstant value = (BonoboConstant) ctx.getReturnValue();
            if (value.getType() instanceof BonoboIntegerType) {
                blockCompiler.emit(new BananaReturnConstantInstruction(value));
                return null;
            }
        }

        // TODO: Other returns
        return null;
    }
}
