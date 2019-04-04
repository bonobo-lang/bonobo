package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.*;

public class BananaStatementCompiler implements BonoboStatementVisitor {
    private final BananaBlockCompiler blockCompiler;
    private final BonoboBlockState state;

    public BananaStatementCompiler(BananaBlockCompiler blockCompiler, BonoboBlockState state) {
        this.blockCompiler = blockCompiler;
        this.state = state;
    }

    public BananaValue compileValue(BonoboValue value) {
        BananaValueCompiler valueCompiler = new BananaValueCompiler(blockCompiler, state);
        return value.accept(valueCompiler);
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
        // Step 1: Compile the value.
        BananaValue value = compileValue(ctx.getSymbol().getValue());

        // TODO: Prevent assigning result of "void" call

        if (value == null) {
            // TODO: What if this is null?
            return null;
        }

        // Step 2: Create the SSA variable.
        String name = ctx.getSymbol().getName();
        BananaType type = value.getType();
        BananaVariable variable = blockCompiler.getBananaPass().createVariable(name, type);

        // Step 3: Associate the symbol in question with the banana variable.
        ctx.getSymbol().setBanana(variable);

        // Step 4: Emit an assign instruction.
        blockCompiler.emit(new BananaAssignInstruction(variable, value));
        return null;
    }
}
