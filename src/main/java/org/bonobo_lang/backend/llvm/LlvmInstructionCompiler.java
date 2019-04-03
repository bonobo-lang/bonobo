package org.bonobo_lang.backend.llvm;

import org.bonobo_lang.analysis.BonoboIntegerType;
import org.bonobo_lang.banana.BananaInstructionVisitor;
import org.bonobo_lang.banana.BananaReturnConstantInstruction;

public class LlvmInstructionCompiler implements BananaInstructionVisitor {
    private final LlvmBackend llvmBackend;

    public LlvmInstructionCompiler(LlvmBackend llvmBackend) {
        this.llvmBackend = llvmBackend;
    }

    @Override
    public Object visitReturnConstant(BananaReturnConstantInstruction ctx) {
        if (ctx.getValue().getType() instanceof BonoboIntegerType) {
            BonoboIntegerType type = (BonoboIntegerType) ctx.getValue().getType();
            llvmBackend.writeln(String.format("ret %s %d", type.getName(), ctx.getValue().asLong()));
        }

        // TODO: Other constants
        return null;
    }
}
