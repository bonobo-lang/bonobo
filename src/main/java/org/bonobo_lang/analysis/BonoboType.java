package org.bonobo_lang.analysis;

public abstract class BonoboType {
    public abstract String getName();

    public abstract boolean isExactly(BonoboType other);

    public abstract BonoboType getParent();

    public <T> T accept(BonoboTypeVisitor<T> visitor) {
        throw new UnsupportedOperationException();
    }

    public boolean isAssignableTo(BonoboType other) {
        BonoboType type = other;

        while (type != null) {
            if (type.isExactly(this)) return true;
            type = type.getParent();
        }

        return false;
    }
}
