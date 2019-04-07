package org.bonobo_lang.analysis;

public abstract class BonoboTypeVisitor<T> {
    public T visitIntegerType(BonoboIntegerType ctx) {
        throw new UnsupportedOperationException();
    }

    public T visitVoidType(BonoboVoidType ctx) {
        throw new UnsupportedOperationException();
    }
}
