package org.bonobo_lang.analysis;

import org.bonobo_lang.banana.BonoboStatementVisitor;

public abstract class BonoboStatement {
    private final SourceLocation location;
    private final BonoboScope scope;

    public <T> T accept(BonoboStatementVisitor<T> visitor) {
        throw new UnsupportedOperationException();
    }

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
