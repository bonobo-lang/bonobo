package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

public class BonoboFunction extends BonoboValue {
    private BonoboParser.FnDeclContext declaration;
    private final BonoboModule module;
    private final BonoboScope scope;
    private final String name;
    private BonoboType returnType;

    public BonoboFunction(BonoboScope scope, BonoboModule module, String name) {
        this.module = module;
        this.name = name;
        this.scope = scope;
        returnType = new BonoboUnknownType();
    }

    public BonoboModule getModule() {
        return module;
    }

    public BonoboScope getScope() {
        return scope;
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

    public BonoboType getReturnType() {
        return returnType;
    }

    public void setReturnType(BonoboType returnType) {
        this.returnType = returnType;
    }
}
