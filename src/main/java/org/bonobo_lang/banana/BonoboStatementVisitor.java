package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboReturnStatement;
import org.bonobo_lang.analysis.BonoboVariableDeclarationStatement;

public interface BonoboStatementVisitor<T> {
    T visitReturn(BonoboReturnStatement ctx);

    T visitVariableDeclaration(BonoboVariableDeclarationStatement ctx);
}
