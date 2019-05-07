package org.bonobo_lang.analysis;

public interface BonoboValueVisitor<T> {
    T visitConstant(BonoboConstant ctx);

    T visitFunction(BonoboFunction ctx);

    T visitVariableGet(BonoboVariableGet ctx);
}
