package org.bonobo_lang.banana;

public interface BananaInstructionVisitor<T> {
    T visitReturnConstant(BananaReturnConstantInstruction ctx);
}
