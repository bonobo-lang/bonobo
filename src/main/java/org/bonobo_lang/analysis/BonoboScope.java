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

    public BonoboScope getParent() {
        return parent;
    }

    public List<BonoboSymbol> getSymbols() {
        return symbols;
    }

    public BonoboScope createChild() {
        return new BonoboScope(this);
    }

    public BonoboSymbol create(SourceLocation location, String name, BonoboValue value) {
        return create(new BonoboSymbol(location, name, value));
    }

    public BonoboSymbol create(SourceLocation location, String name, BonoboType type) {
        return create(new BonoboSymbol(location, name, type));
    }

    private BonoboSymbol create(BonoboSymbol symbol) throws IllegalStateException {
        for (BonoboSymbol sym : symbols) {
            if (sym.getName().equals(symbol.getName())) {
                String msg = String.format("The symbol \"%s\" already exists in the current context.", symbol.getName());
                throw new IllegalStateException(msg);
            }
        }

        symbols.add(symbol);
        return symbol;
    }

    public boolean canDefine(String name) {
        for (BonoboSymbol sym : symbols) {
            if (sym.getName().equals(name)) {
                return false;
            }
        }

        return true;
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
