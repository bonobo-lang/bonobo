package org.bonobo_lang.banana;

public abstract class BananaTypeVisitor<T> {
    public T visitIntegerType(BananaIntegerType ctx) {
        throw new UnsupportedOperationException();
    }

    public T visitVoidType(BananaVoidType ctx) {
        throw new UnsupportedOperationException();
    }
}
