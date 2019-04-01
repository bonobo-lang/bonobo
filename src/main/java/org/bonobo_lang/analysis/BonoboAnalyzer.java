package org.bonobo_lang.analysis;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.bonobo_lang.frontend.BonoboParser;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BonoboAnalyzer extends BaseErrorListener {
    private final BonoboCoreModule coreModule;
    private final List<BonoboError> errors = new ArrayList<>();
    private final Map<String, BonoboModule> moduleCache = new HashMap<>();
    private final BonoboScope rootScope = new BonoboScope();

    public BonoboAnalyzer() {
        this.coreModule = new BonoboCoreModule(rootScope);
    }

    public List<BonoboError> getErrors() {
        return errors;
    }

    public BonoboCoreModule getCoreModule() {
        return coreModule;
    }

    public BonoboScope getRootScope() {
        return rootScope;
    }

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
        SourceLocation location = new SourceLocation(e.getInputStream().getSourceName(), line, charPositionInLine);
        errors.add(new BonoboError(BonoboError.Severity.error, location, msg));
        super.syntaxError(recognizer, offendingSymbol, line, charPositionInLine, msg, e);
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
        BonoboModule module = new BonoboModule(rootScope.createChild(), uri, ctx);
        moduleCache.put(uri, module);

        // Conduct a cursory glance at the module in question.
        new BonoboCursoryGlance(this, module).run();

        return module;
    }
}