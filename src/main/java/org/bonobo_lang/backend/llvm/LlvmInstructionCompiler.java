package org.bonobo_lang.backend.llvm;

import org.bonobo_lang.analysis.BonoboIntegerType;
import org.bonobo_lang.banana.BananaAssignInstruction;
import org.bonobo_lang.banana.BananaConstant;
import org.bonobo_lang.banana.BananaInstructionVisitor;
import org.bonobo_lang.banana.BananaReturnConstantInstruction;

public class LlvmInstructionCompiler extends BananaInstructionVisitor {
    private final LlvmBackend llvmBackend;

    public LlvmInstructionCompiler(LlvmBackend llvmBackend) {
        this.llvmBackend = llvmBackend;
    }

    public Object visitReturnConstant(BananaReturnConstantInstruction ctx) {
        if (ctx.getValue().getType() instanceof BonoboIntegerType) {
            BonoboIntegerType type = (BonoboIntegerType) ctx.getValue().getType();
            llvmBackend.writeln(String.format("ret %s %d", type.getName(), ctx.getValue().asLong()));
        }

        // TODO: Other constants
        return null;
    }

    public Object visitAssign(BananaAssignInstruction ctx) {
        LlvmTypeCompiler typeCompiler = new LlvmTypeCompiler();
        String llvmType = ctx.getValue().getType().accept(typeCompiler);

        if (llvmType == null) {
            // TODO: What if this is null?
            return null;
        }

        LlvmValueCompiler valueCompiler = new LlvmValueCompiler();
        String llvmValue;
        boolean needsAssignment = true;

        // If it's a constant, use a "store" instead.
        if (ctx.getValue() instanceof BananaConstant) {
            needsAssignment = false;
            // store i32 0, i32* %i, align 4
            if (((BananaConstant) ctx.getValue()).getUnderlying().getType() instanceof BonoboIntegerType) {
                llvmValue = String.format("store %s %d, %s* %%%s, align 4",
                        llvmType,
                        ((BananaConstant) ctx.getValue()).getUnderlying().asLong(),
                        llvmType,
                        ctx.getVariable().getName());
            } else {
                // TODO: Other constants
                llvmValue = null;
            }
        } else {
            llvmValue = ctx.getValue().accept(valueCompiler);
        }

        if (llvmValue == null) {
            // TODO: What if this is null?
            return null;
        }

        // If this is the first usage of the variable, allocate it first.
        if (ctx.isInitial()) {
            llvmBackend.writeln(String.format("%%%s = alloca %s, align 4", ctx.getVariable().getName(), llvmType));
        }

        if (needsAssignment)
            llvmBackend.writeln(String.format("%%%s = %s", ctx.getVariable().getName(), llvmValue));
        else llvmBackend.writeln(llvmValue);
        return null;
    }
}
