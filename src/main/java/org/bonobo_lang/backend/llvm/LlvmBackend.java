package org.bonobo_lang.backend.llvm;

import org.bonobo_lang.banana.*;

public class LlvmBackend {
    private final StringBuilder stringBuilder = new StringBuilder();
    private final BananaModule module;
    private int indentationLevel = 0;

    public LlvmBackend(BananaModule module) {
        this.module = module;
    }

    public StringBuilder getStringBuilder() {
        return stringBuilder;
    }

    public void indent() {
        indentationLevel++;
    }

    public void outdent() {
        if (indentationLevel > 0) indentationLevel--;
    }

    public void write(String s) {
        for (int i = 0; i < indentationLevel; i++)
            stringBuilder.append("  ");
        stringBuilder.append(s);
    }

    public void writeln(String s) {
        write(String.format("%s%n", s));
    }

    public void compile() {
        for (BananaFunction fn : module.getFunctions()) {
            compileFunction(fn);
        }
    }

    public void compileFunction(BananaFunction ctx) {
        String type = ctx.getReturnType().accept(new LlvmTypeCompiler());
        writeln(String.format("define %s @%s () {", type, ctx.getName()));
        indent();
        for (BananaBlock block : ctx.getBlocks()) compileBlock(block);
        outdent();

        // If the function returns void, add a "ret void"
        if (ctx.getReturnType() instanceof BananaVoidType)
            writeln("ret void");

        writeln("}");
    }

    public void compileBlock(BananaBlock block) {
        writeln(String.format("%s:", block.getName()));
        indent();
        for (BananaInstruction instr : block.getInstructions())
            compileInstruction(instr);
        outdent();
    }

    public void compileInstruction(BananaInstruction ctx) {
        ctx.accept(new LlvmInstructionCompiler(this));
    }
}
