package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

public class BonoboFunction extends BonoboValue {
    private BonoboParser.FnDeclContext declaration;
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

    public BonoboParser.FnDeclContext getDeclaration() {
        return declaration;
    }

    public void setDeclaration(BonoboParser.FnDeclContext declaration) {
        this.declaration = declaration;
    }
}
