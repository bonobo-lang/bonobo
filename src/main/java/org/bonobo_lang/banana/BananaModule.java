package org.bonobo_lang.banana;

import java.util.ArrayList;
import java.util.List;

public class BananaModule {
    private final List<BananaFunction> functions = new ArrayList<>();
    private final String name;

    public BananaModule(String name) {
        this.name = name;
    }

    public List<BananaFunction> getFunctions() {
        return functions;
    }

    public String getName() {
        return name;
    }
}
