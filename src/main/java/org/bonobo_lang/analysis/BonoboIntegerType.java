package org.bonobo_lang.analysis;

public class BonoboIntegerType extends BonoboNumericType {
    private String name;
    private long size;
    private boolean unsigned;

    public BonoboIntegerType(String name, long size, boolean unsigned) {
        this.name = name;
        this.size = size;
        this.unsigned = unsigned;
    }

    @Override
    public String getName() {
        return name;
    }

    public long getSize() {
        return size;
    }

    public boolean isUnsigned() {
        return unsigned;
    }

    @Override
    public boolean isExactly(BonoboType other) {
        return false;
    }

    @Override
    public BonoboType getParent() {
        return null;
    }

    @Override
    public <T> T accept(BonoboTypeVisitor<T> visitor) {
        return visitor.visitIntegerType(this);
    }
}
