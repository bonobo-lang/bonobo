package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

public class BonoboFunction extends BonoboValue {
    private BonoboParser.FnDeclContext declaration;
    private final BonoboModule module;
    private final BonoboScope scope;
    private final String name;
    private BonoboBlock body;

    public BonoboFunction(SourceLocation location, BonoboScope scope, BonoboModule module, String name) {
        super(location, null); // TODO: Types of functions
        this.module = module;
        this.name = name;
        this.scope = scope;
        body = new BonoboBlock(scope);
    }

    public BonoboBlock getBody() {
        return body;
    }

    public void setBody(BonoboBlock body) {
        this.body = body;
    }

    public BonoboParser.BlockContext getBlock(){
        if (declaration != null) {
            return declaration.block();
        } else {
            return null;
        }
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

    @Override
    public <T> T accept(BonoboValueVisitor<T> visitor) {
        return visitor.visitFunction(this);
    }
}
