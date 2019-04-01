package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BonoboAnalyzer {
    private final BonoboCoreTypes coreTypes = new BonoboCoreTypes();
    private final List<BonoboError> errors = new ArrayList<>();
    private final Map<String, BonoboModule> moduleCache = new HashMap<>();
    private final BonoboScope rootScope = new BonoboScope();

    public List<BonoboError> getErrors() {
        return errors;
    }

    public BonoboModule analyzeIdempotent(String uri, BonoboParser.ProgContext ctx) {
        if (moduleCache.containsKey(uri)) {
            return moduleCache.get(uri);
        } else {
            // `analyze` puts the module in the cache.
            return analyze(uri, ctx);
        }
    }

    public BonoboModule analyze(String uri, BonoboParser.ProgContext ctx) {
        // Create the module.
        BonoboModule module = new BonoboModule(rootScope.createChild(), uri);
        moduleCache.put(uri, module);

        // Conduct a cursory glance at the module in question.

        return module;
    }
}
