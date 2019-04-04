package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboConstant;

public class BananaConstant extends BananaValue {
    private final BonoboConstant underlying;

    public BananaConstant(BananaType type, BonoboConstant underlying) {
        super(type);
        this.underlying = underlying;
    }

    public BonoboConstant getUnderlying() {
        return underlying;
    }

    @Override
    public <T> T accept(BananaValueVisitor<T> visitor) {
        return visitor.visitConstant(this);
    }
}
