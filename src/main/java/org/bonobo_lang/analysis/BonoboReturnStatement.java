package org.bonobo_lang.analysis;

import org.bonobo_lang.banana.BonoboStatementVisitor;

public class BonoboReturnStatement extends BonoboStatement {
    private final BonoboValue returnValue;

    public BonoboReturnStatement(SourceLocation location, BonoboScope scope, BonoboValue returnValue) {
        super(location, scope);
        this.returnValue = returnValue;
    }

    public BonoboValue getReturnValue() {
        return returnValue;
    }

    @Override
    public <T> T accept(BonoboStatementVisitor<T> visitor) {
        return visitor.visitReturnStatement(this);
    }
}
