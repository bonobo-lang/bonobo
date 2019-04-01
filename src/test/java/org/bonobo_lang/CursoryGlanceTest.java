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

import static org.junit.Assert.*;

public class CursoryGlanceTest {
    BonoboModule analyze(String src) {
        CharStream charStream = CharStreams.fromString(src, "<test srcs>");
        BonoboAnalyzer analyzer = new BonoboAnalyzer();
        BonoboLexer lexer = new BonoboLexer(charStream);
        lexer.removeErrorListeners();
        lexer.addErrorListener(analyzer);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        BonoboParser parser = new BonoboParser(tokenStream);
        parser.removeErrorListeners();
        parser.addErrorListener(analyzer);
        BonoboParser.ProgContext prog = parser.prog();
        assertNotNull(prog);
        assertEquals(analyzer.getErrors().size(), 0);
        BonoboModule module = analyzer.analyze("<test srcs>", prog);

        for (BonoboError err : analyzer.getErrors()) {
            System.out.printf("%s: %s\n", err.getLocation().toString(), err.getMessage());
        }

        return module;

    }

    @Test
    public void shouldGatherFunctions() {
        String src = "fn main => 1\n" +
                "fn main2 => 2";
        BonoboModule module = analyze(src);
        assertEquals(module.getScope().getSymbols().size(), 2);

        BonoboFunction main = (BonoboFunction) module.getScope().resolve("main").getValue();
        BonoboFunction main2 = (BonoboFunction) module.getScope().resolve("main2").getValue();
        assertEquals(main.getName(), "main");
        assertEquals(main2.getName(), "main2");
    }
}
