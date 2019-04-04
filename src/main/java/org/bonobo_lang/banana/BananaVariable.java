package org.bonobo_lang.banana;

public class BananaVariable {
    private final String name;
    private final BananaType type;

    public BananaVariable(String name, BananaType type) {
        this.name = name;
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public BananaType getType() {
        return type;
    }
}
