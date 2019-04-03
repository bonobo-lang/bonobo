package org.bonobo_lang;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.bonobo_lang.analysis.BonoboAnalyzer;
import org.bonobo_lang.analysis.BonoboError;
import org.bonobo_lang.analysis.BonoboFunction;
import org.bonobo_lang.analysis.BonoboModule;
import org.bonobo_lang.frontend.BonoboLexer;
import org.bonobo_lang.frontend.BonoboParser;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

public class CursoryGlanceTest {
    private BonoboParser.ProgContext parse(String src, BonoboAnalyzer analyzer) {
        CharStream charStream = CharStreams.fromString(src, "<test srcs>");
        BonoboLexer lexer = new BonoboLexer(charStream);
        lexer.removeErrorListeners();
        lexer.addErrorListener(analyzer);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        BonoboParser parser = new BonoboParser(tokenStream);
        parser.removeErrorListeners();
        parser.addErrorListener(analyzer);
        BonoboParser.ProgContext prog = parser.prog();
        assertNotNull(prog);
        return prog;
    }

    private BonoboModule analyzeModule(String src) {
        BonoboAnalyzer analyzer = new BonoboAnalyzer();
        BonoboParser.ProgContext prog = parse(src, analyzer);

        for (BonoboError err : analyzer.getErrors()) {
            System.out.printf("%s: %s\n", err.getLocation().toString(), err.getMessage());
        }

        return analyzer.analyzeCursory("<test srcs>", prog);

    }

    @Test
    public void shouldGatherFunctions() {
        String src = "fn main => 1\n" +
                "fn main2 => 2";
        BonoboModule module = analyzeModule(src);
        assertEquals(2, module.getScope().getSymbols().size());

        BonoboFunction main = (BonoboFunction) module.getScope().resolve("main").getValue();
        BonoboFunction main2 = (BonoboFunction) module.getScope().resolve("main2").getValue();
        assertEquals("main", main.getName());
        assertEquals("main2", main2.getName());
    }

    @Test
    public void cannotRedefineNames() {
        String src = "fn main => 1\n" +
                "fn main => 2";
        BonoboAnalyzer analyzer = new BonoboAnalyzer();
        BonoboParser.ProgContext prog = parse(src, analyzer);
        BonoboModule module = analyzer.analyzeCursory("<test srcs>", prog);
        assertEquals(1, module.getScope().getSymbols().size());
        assertTrue(!analyzer.getErrors().isEmpty());
    }
}
