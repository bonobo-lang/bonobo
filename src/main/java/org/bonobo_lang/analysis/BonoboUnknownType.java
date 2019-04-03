package org.bonobo_lang.analysis;

public class BonoboUnknownType extends BonoboType {
    @Override
    public String getName() {
        return "?";
    }

    @Override
    public boolean isExactly(BonoboType other) {
        return other instanceof BonoboUnknownType;
    }

    @Override
    public BonoboType getParent() {
        return null;
    }

    @Override
    public <T> T accept(BonoboTypeVisitor<T> visitor) {
        throw new UnsupportedOperationException("The unknown type indicates an error, cannot be compiled.");
    }
}
