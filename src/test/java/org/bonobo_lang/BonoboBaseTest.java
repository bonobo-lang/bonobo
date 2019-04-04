package org.bonobo_lang;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.bonobo_lang.analysis.*;

import static org.junit.Assert.assertNotNull;

public abstract class BonoboBaseTest {
    protected org.bonobo_lang.frontend.BonoboParser.ProgContext parse(String src, BonoboAnalyzer analyzer) {
        CharStream charStream = CharStreams.fromString(src, "<test srcs>");
        org.bonobo_lang.frontend.BonoboLexer lexer = new org.bonobo_lang.frontend.BonoboLexer(charStream);
        lexer.removeErrorListeners();
        lexer.addErrorListener(analyzer);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        org.bonobo_lang.frontend.BonoboParser parser = new org.bonobo_lang.frontend.BonoboParser(tokenStream);
        parser.removeErrorListeners();
        parser.addErrorListener(analyzer);
        org.bonobo_lang.frontend.BonoboParser.ProgContext prog = parser.prog();
        assertNotNull(prog);
        return prog;
    }

    protected BonoboModule cursoryAnalyzeModule(String src) {
        BonoboAnalyzer analyzer = new BonoboAnalyzer();
        org.bonobo_lang.frontend.BonoboParser.ProgContext prog = parse(src, analyzer);

        for (BonoboError err : analyzer.getErrors()) {
            System.out.printf("%s: %s\n", err.getLocation().toString(), err.getMessage());
        }

        return analyzer.analyzeCursory("<test srcs>", prog);
    }

    protected BonoboModule fullAnalyzeModule(String src) {
        BonoboAnalyzer analyzer = new BonoboAnalyzer();
        org.bonobo_lang.frontend.BonoboParser.ProgContext prog = parse(src, analyzer);

        for (BonoboError err : analyzer.getErrors()) {
            System.out.printf("%s: %s\n", err.getLocation().toString(), err.getMessage());
        }

        return analyzer.analyzeInFull("<test srcs>", prog);
    }

    protected BonoboSymbol findSymbol(String src, String name) {
        BonoboModule module = fullAnalyzeModule(src);
        return module.getScope().resolve(name);
    }
}
