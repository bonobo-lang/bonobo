package org.bonobo_lang.backend.llvm;

import org.bonobo_lang.analysis.BonoboIntegerType;
import org.bonobo_lang.banana.BananaAssignInstruction;
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

    @Override
    public Object visitAssign(BananaAssignInstruction ctx) {
        LlvmTypeCompiler typeCompiler = new LlvmTypeCompiler();
        String llvmType = ctx.getValue().getType().accept(typeCompiler);

        if (llvmType == null) {
            // TODO: What if this is null?
            return null;
        }

        // If this is the first usage of the variable, allocate it first.
        if (ctx.isInitial()) {
            llvmBackend.writeln(String.format("%%%s = alloca %s, align 4", ctx.getVariable().getName(), llvmType));
        }

        // TODO: Perform assignment

        return null;
    }
}
