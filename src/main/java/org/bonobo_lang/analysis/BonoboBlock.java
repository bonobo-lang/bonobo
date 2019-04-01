package org.bonobo_lang.analysis;

import java.util.ArrayList;
import java.util.List;

public class BonoboBlock {
    private final List<BonoboStatement> body = new ArrayList<>();
    private final BonoboScope scope;

    public BonoboBlock(BonoboScope scope) {
        this.scope = scope;
    }

    public List<BonoboStatement> getBody() {
        return body;
    }

    public BonoboScope getScope() {
        return scope;
    }
}
