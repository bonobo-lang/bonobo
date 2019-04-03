package org.bonobo_lang.analysis;

import java.util.ArrayList;
import java.util.List;

public class BonoboBlock {
    private final List<BonoboBlockState> body = new ArrayList<>();
    private BonoboType returnType;
    private final BonoboScope scope;

    public BonoboBlock(BonoboScope scope) {
        this.scope = scope;
        returnType = new BonoboUnknownType();
    }

    public List<BonoboBlockState> getBody() {
        return body;
    }

    public BonoboType getReturnType() {
        return returnType;
    }

    public BonoboScope getScope() {
        return scope;
    }
}
