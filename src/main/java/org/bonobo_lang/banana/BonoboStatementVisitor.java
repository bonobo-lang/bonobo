package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboReturnStatement;

public interface BonoboStatementVisitor<T> {
    T visitReturnStatement(BonoboReturnStatement ctx);
}
