package org.bonobo_lang.analysis;

import org.bonobo_lang.banana.BonoboStatementVisitor;

public class BonoboVariableDeclarationStatement extends BonoboStatement {
    private final BonoboSymbol symbol;

    public BonoboVariableDeclarationStatement(BonoboScope scope, BonoboSymbol symbol) {
        super(symbol.getLocation(), scope);
        this.symbol = symbol;
    }

    public BonoboSymbol getSymbol() {
        return symbol;
    }

    @Override
    public <T> T accept(BonoboStatementVisitor<T> visitor) {
        return visitor.visitVariableDeclaration(this);
    }
}
