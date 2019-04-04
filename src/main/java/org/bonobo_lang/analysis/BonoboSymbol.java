package org.bonobo_lang.analysis;

import org.bonobo_lang.banana.BananaVariable;

// TODO: Track symbol usages
public class BonoboSymbol {
    private SourceLocation location;
    private String name;
    private BonoboValue value;
    private BonoboType type;
    private BananaVariable banana = null;

    public BonoboSymbol(SourceLocation location, String name, BonoboValue value) {
        this.location = location;
        this.name = name;
        this.value = value;
    }

    public BonoboSymbol(SourceLocation location, String name, BonoboType type) {
        this.location = location;
        this.name = name;
        this.type = type;
    }

    public BananaVariable getBanana() {
        return banana;
    }

    public String getName() {
        return name;
    }

    public BonoboValue getValue() {
        return value;
    }

    public BonoboType getType() {
        return type;
    }

    public SourceLocation getLocation() {
        return location;
    }

    public boolean isType() {
        return type != null;
    }

    public boolean isValue() {
        return value != null;
    }

    public void setBanana(BananaVariable variable) {
        banana = variable;
    }
}
