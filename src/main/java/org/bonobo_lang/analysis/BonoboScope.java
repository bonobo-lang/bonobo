package org.bonobo_lang.analysis;

import java.util.ArrayList;
import java.util.List;

public class BonoboScope {
    private BonoboScope parent;
    private List<BonoboSymbol> symbols = new ArrayList<>();

    public BonoboScope() {
        parent = null;
    }

    private BonoboScope(BonoboScope parent) {
        this.parent = parent;
    }

    public boolean isRoot() {
        return parent == null;
    }

    public BonoboSymbol resolve(String name) {
        for (BonoboSymbol symbol : symbols) {
            if (symbol.getName().equals(name)) {
                return symbol;
            }
        }

        if (!isRoot()) {
            return parent.resolve(name);
        } else {
            return null;
        }
    }
}
