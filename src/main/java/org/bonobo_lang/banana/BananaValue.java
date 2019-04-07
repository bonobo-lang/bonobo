package org.bonobo_lang.banana;

public abstract class BananaValue {
    private final BananaType type;

    public BananaValue(BananaType type) {
        this.type = type;
    }

    public BananaType getType() {
        return type;
    }

    public <T> T accept(BananaValueVisitor<T> visitor) {
        throw new UnsupportedOperationException();
    }
}
