package org.bonobo_lang.banana;

public abstract class BananaInstructionVisitor<T> {
    T visitReturnConstant(BananaReturnConstantInstruction ctx) {
        throw new UnsupportedOperationException();
    }

    T visitAssign(BananaAssignInstruction ctx) {
        throw new UnsupportedOperationException();
    }
}
