package org.bonobo_lang.analysis;

public class BonoboFunction extends BonoboValue {
    private final BonoboModule module;
    private final String name;

    public BonoboFunction(BonoboModule module, String name) {
        this.module = module;
        this.name = name;
    }

    public BonoboModule getModule() {
        return module;
    }

    public String getName() {
        return name;
    }
}
