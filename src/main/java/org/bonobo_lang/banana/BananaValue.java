package org.bonobo_lang.banana;

public class BananaValue {
    private final BananaType type;

    public BananaValue(BananaType type) {
        this.type = type;
    }

    public BananaType getType() {
        return type;
    }
}
