package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.*;

public class BananaStatementCompiler implements BonoboStatementVisitor {
    private final BananaBlockCompiler blockCompiler;
    private final BonoboBlockState state;

    public BananaStatementCompiler(BananaBlockCompiler blockCompiler, BonoboBlockState state) {
        this.blockCompiler = blockCompiler;
        this.state = state;
    }

    @Override
    public Object visitReturn(BonoboReturnStatement ctx) {
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

    @Override
    public Object visitVariableDeclaration(BonoboVariableDeclarationStatement ctx) {
        // TLDR: Declare an SSA variable, emit an assignment instruction.

        return null;
    }
}
