package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboIntegerType;

public class BananaIntegerType extends BananaType {
    private final BonoboIntegerType underlying;

    public BananaIntegerType(BonoboIntegerType underlying) {
        this.underlying = underlying;
    }

    public BonoboIntegerType getUnderlying() {
        return underlying;
    }

    @Override
    public String getName() {
        return underlying.getName();
    }

    @Override
    public long computeSize(BananaSystem system) {
        return underlying.getSize();
    }

    @Override
    public <T> T accept(BananaTypeVisitor<T> visitor) {
        return visitor.visitIntegerType(this);
    }
}
