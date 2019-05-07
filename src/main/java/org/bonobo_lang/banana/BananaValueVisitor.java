package org.bonobo_lang.banana;

public interface BananaValueVisitor<T> {
    T visitConstant(BananaConstant ctx);
}
