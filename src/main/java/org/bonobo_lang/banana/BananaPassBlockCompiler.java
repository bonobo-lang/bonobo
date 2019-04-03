package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboBlockState;
import org.bonobo_lang.analysis.BonoboFunction;
import org.bonobo_lang.frontend.BonoboBaseVisitor;

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

    public BananaPass getBananaPass() {
        return bananaPass;
    }

    public BonoboFunction getBonoboFunction() {
        return bonoboFunction;
    }

    public BananaFunction getBananaFunction() {
        return bananaFunction;
    }

    public BananaBlock getBlock() {
        return block;
    }

    public void emit(BananaInstruction instruction) {
        block.getInstructions().add(instruction);
    }

    void run() {
        for (BonoboBlockState state : bonoboFunction.getBody().getBody()) {
            BananaPassStatementCompiler statementCompiler = new BananaPassStatementCompiler(this, state);
            state.getStatement().accept(statementCompiler);
            if (state.isTerminated()) break; // Eliminate dead code; don't bother even compiling it.
        }
    }
}
