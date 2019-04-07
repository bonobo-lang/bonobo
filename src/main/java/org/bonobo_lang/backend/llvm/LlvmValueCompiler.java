package org.bonobo_lang.backend.llvm;

import org.bonobo_lang.analysis.BonoboConstant;
import org.bonobo_lang.analysis.BonoboIntegerType;
import org.bonobo_lang.banana.BananaConstant;
import org.bonobo_lang.banana.BananaValueVisitor;

public class LlvmValueCompiler extends BananaValueVisitor<String> {
    public String visitConstant(BananaConstant ctx) {
        BonoboConstant underlying = ctx.getUnderlying();

        if (underlying.getType() instanceof BonoboIntegerType) {
            return String.format("%s %d", underlying.getType().getName(), underlying.asLong());
        }

        // TODO: Other constants
        return null;
    }
}
