package org.bonobo_lang.backend.llvm;

import org.bonobo_lang.banana.BananaIntegerType;
import org.bonobo_lang.banana.BananaTypeVisitor;

public class LlvmTypeCompiler implements BananaTypeVisitor<String> {
    @Override
    public String visitIntegerType(BananaIntegerType ctx) {
        return ctx.getName();
    }
}
