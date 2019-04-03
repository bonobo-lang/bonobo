package org.bonobo_lang.analysis;

public class BonoboBlockState {
    private final BonoboScope scope;
    private final BonoboBlockState parent;
    private BonoboStatement statement;
    private BonoboValue returnValue;
    private boolean terminated = false;

    public BonoboBlockState(BonoboScope scope) {
        this.parent = null;
        this.scope = scope;
    }

    private BonoboBlockState(BonoboBlockState parent, BonoboScope scope) {
        this.parent = parent;
        this.scope = scope;
    }

    public BonoboBlockState createChild(BonoboScope scope) {
        return new BonoboBlockState(this, scope);
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

    public void setStatement(BonoboStatement statement) {
        this.statement = statement;
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

    public BonoboScope getScope() {
        return scope;
    }

    public BonoboBlockState getParent() {
        return parent;
    }
}
