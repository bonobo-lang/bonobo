package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

public class BonoboFunction extends BonoboValue {
    private final BonoboBlock body;
    private BonoboParser.FnDeclContext declaration;
    private final BonoboModule module;
    private final BonoboScope scope;
    private final String name;
    private BonoboType returnType;

    public BonoboFunction(SourceLocation location, BonoboScope scope, BonoboModule module, String name) {
        super(location, null); // TODO: Types of functions
        this.module = module;
        this.name = name;
        this.scope = scope;
        body = new BonoboBlock(scope);
        returnType = new BonoboUnknownType();
    }

    public BonoboBlock getBody() {
        return body;
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
