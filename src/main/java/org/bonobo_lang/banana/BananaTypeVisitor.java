package org.bonobo_lang.banana;

public interface BananaTypeVisitor<T> {
    public T visitIntegerType(BananaIntegerType ctx);
}
