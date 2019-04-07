package org.bonobo_lang.banana;

public abstract class BananaValueVisitor<T> {
    T visitConstant(BananaConstant ctx) {
        throw new UnsupportedOperationException();
    }
}
