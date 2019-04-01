package org.bonobo_lang;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.UnbufferedCharStream;
import org.bonobo_lang.analysis.BonoboAnalyzer;
import org.bonobo_lang.frontend.BonoboLexer;
import org.bonobo_lang.frontend.BonoboParser;
import org.junit.Test;

/**
 * Unit test for simple MonkeyBusiness.
 */
public class MonkeyBusinessTest
{
    BonoboAnalyzer analyze(String src) {
        CharStream charStream = CharStreams.fromString(src, "<test srcs>");
        BonoboLexer lexer = new BonoboLexer(charStream);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        BonoboParser parser = new BonoboParser(tokenStream);
        BonoboParser.ProgContext prog = parser.prog();
        assertNotNull(prog);
        BonoboAnalyzer analyzer = new BonoboAnalyzer();
        analyzer.analyze("<test srcs>", prog);
        return analyzer;
    }

    @Test
    public void returnInt() {
        String src = "fn main => 1";
        BonoboAnalyzer analyzer = analyze(src);
        System.out.println("Hey");
    }

    /**
     * Rigorous Test :-)
     */
    @Test
    public void shouldAnswerWithTrue()
    {
        assertTrue( true );
    }
}
