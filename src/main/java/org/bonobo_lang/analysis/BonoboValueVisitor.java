package org.bonobo_lang.analysis;

public abstract class BonoboValueVisitor<T> {
    T visitConstant(BonoboConstant ctx) {
        throw new UnsupportedOperationException();
    }

    T visitFunction(BonoboFunction ctx) {
        throw new UnsupportedOperationException();
    }

    T visitVariableGet(BonoboVariableGet ctx) {
        throw new UnsupportedOperationException();
    }
}
