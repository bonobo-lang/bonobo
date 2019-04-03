package org.bonobo_lang.analysis;

public class BonoboReturnStatement extends BonoboStatement {
    private final BonoboValue returnValue;

    public BonoboReturnStatement(SourceLocation location, BonoboScope scope, BonoboValue returnValue) {
        super(location, scope);
        this.returnValue = returnValue;
    }

    public BonoboValue getReturnValue() {
        return returnValue;
    }
}
