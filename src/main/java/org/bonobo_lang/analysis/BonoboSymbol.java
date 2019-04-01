package org.bonobo_lang.analysis;

public class BonoboSymbol {
    private SourceLocation location;
    private String name;
    private BonoboValue value;

    public BonoboSymbol(SourceLocation location, String name, BonoboValue value) {
        this.location = location;
        this.name = name;
        this.value = value;
    }

    public String getName() {
        return name;
    }

    public BonoboValue getValue() {
        return value;
    }

    public SourceLocation getLocation() {
        return location;
    }
}
