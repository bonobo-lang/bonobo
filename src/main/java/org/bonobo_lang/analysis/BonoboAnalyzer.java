package org.bonobo_lang.analysis;

import org.bonobo_lang.frontend.BonoboParser;

import java.util.ArrayList;
import java.util.List;

public class BonoboAnalyzer {
    private final List<BonoboError> errors = new ArrayList<>();
    // TODO: Only analyze a file once
    // private final Map<String>

    public List<BonoboError> getErrors() {
        return errors;
    }

    public void analyze(String uri, BonoboParser.ProgContext ctx) {
        // TODO: Analyze
    }
}
