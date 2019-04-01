package org.bonobo_lang.analysis;

// Every Bonobo file its own module.
public class BonoboModule {
    private BonoboScope scope;
    private String sourceUrl;

    public BonoboModule(BonoboScope scope, String sourceUrl) {
        this.scope = scope;
        this.sourceUrl = sourceUrl;
    }

    public BonoboScope getScope() {
        return scope;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }
}
