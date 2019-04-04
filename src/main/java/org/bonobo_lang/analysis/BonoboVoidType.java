package org.bonobo_lang.analysis;

public class BonoboVoidType extends BonoboType {
    @Override
    public String getName() {
        return "void";
    }

    @Override
    public boolean isExactly(BonoboType other) {
        return other instanceof BonoboVoidType;
    }

    @Override
    public BonoboType getParent() {
        return null;
    }

    @Override
    public <T> T accept(BonoboTypeVisitor<T> visitor) {
        return visitor.visitVoidType(this);
    }
}
