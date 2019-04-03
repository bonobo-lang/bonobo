package org.bonobo_lang.analysis;

public interface BonoboTypeVisitor<T> {
    public T visitIntegerType(BonoboIntegerType ctx);
}
