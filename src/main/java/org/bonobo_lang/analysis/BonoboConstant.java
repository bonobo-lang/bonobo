package org.bonobo_lang.analysis;

public class BonoboConstant extends BonoboValue {
    private final Object value;

    public BonoboConstant(SourceLocation location, BonoboType type, long value) {
        super(location, type);
        this.value = value;
    }

    public Object getValue() {
        return value;
    }

    public long asLong() {
        return (long) value;
    }

    @Override
    public <T> T accept(BonoboValueVisitor<T> visitor) {
        return visitor.visitConstant(this);
    }
}
