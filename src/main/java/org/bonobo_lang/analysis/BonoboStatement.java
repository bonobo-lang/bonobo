package org.bonobo_lang.analysis;

public class BonoboStatement {
    private final SourceLocation location;
    private final BonoboScope scope;

    public BonoboStatement(SourceLocation location, BonoboScope scope) {
        this.location = location;
        this.scope = scope;
    }

    public SourceLocation getLocation() {
        return location;
    }

    public BonoboScope getScope() {
        return scope;
    }
}
