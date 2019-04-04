package org.bonobo_lang.analysis;

public abstract class BonoboValue {
    private final SourceLocation location;
    private final BonoboType type;

    public BonoboValue(SourceLocation location, BonoboType type) {
        this.location = location;
        this.type = type;
    }

    public SourceLocation getLocation() {
        return location;
    }

    public BonoboType getType() {
        return type;
    }

    public abstract <T> T accept(BonoboValueVisitor<T> visitor);
}
