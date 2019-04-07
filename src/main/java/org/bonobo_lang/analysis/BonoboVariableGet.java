package org.bonobo_lang.analysis;

public class BonoboVariableGet extends BonoboValue {
    private final BonoboSymbol symbol;

    public BonoboVariableGet(SourceLocation location, BonoboType type, BonoboSymbol symbol) {
        super(location, type);
        this.symbol = symbol;
    }

    public BonoboSymbol getSymbol() {
        return symbol;
    }

    @Override
    public <T> T accept(BonoboValueVisitor<T> visitor) {
        return visitor.visitVariableGet(this);
    }
}
