package org.bonobo_lang.analysis;

public class BonoboBlockState {
    private final BonoboStatement statement;
    private final BonoboBlockState parent;
    private BonoboValue returnValue;
    private boolean terminated = false;

    public BonoboBlockState(BonoboStatement statement) {
        this.statement = statement;
        this.parent = null;
    }

    private BonoboBlockState(BonoboStatement statement, BonoboBlockState parent) {
        this.statement = statement;
        this.parent = parent;
    }

    public BonoboBlockState createChild(BonoboStatement statement) {
        return new BonoboBlockState(statement, this);
    }

    public BonoboStatement getStatement() {
        return statement;
    }

    public BonoboValue getReturnValue() {
        return returnValue;
    }

    public BonoboType getReturnType() {
        if (returnValue != null)
            return returnValue.getType();
        return null;
    }

    public void setReturnValue(BonoboValue returnValue) {
        this.returnValue = returnValue;
    }

    public boolean isTerminated() {
        return terminated;
    }

    public void terminate() {
        terminated = true;
    }
}
