package org.bonobo_lang.backend.llvm;

import org.bonobo_lang.banana.BananaIntegerType;
import org.bonobo_lang.banana.BananaTypeVisitor;
import org.bonobo_lang.banana.BananaVoidType;

public class LlvmTypeCompiler implements BananaTypeVisitor<String> {
    @Override
    public String visitIntegerType(BananaIntegerType ctx) {
        return ctx.getName();
    }

    @Override
    public String visitVoidType(BananaVoidType ctx) {
        return "void";
    }
}
