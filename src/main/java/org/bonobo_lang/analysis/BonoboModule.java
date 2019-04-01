package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

// Every Bonobo file its own module.
public class BonoboModule {
    private BonoboScope scope;
    private String sourceUrl;
    private BonoboParser.ProgContext ctx;

    protected BonoboModule(BonoboScope scope, String sourceUrl) {
        this.scope = scope;
        this.sourceUrl = sourceUrl;
    }

    public BonoboModule(BonoboScope scope, String sourceUrl, BonoboParser.ProgContext ctx) {
        this.scope = scope;
        this.sourceUrl = sourceUrl;
        this.ctx = ctx;
    }

    public BonoboScope getScope() {
        return scope;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public BonoboParser.ProgContext getCtx() {
        return ctx;
    }
}
