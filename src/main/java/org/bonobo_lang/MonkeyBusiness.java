package org.bonobo_lang;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.bonobo_lang.analysis.BonoboAnalyzer;
import org.bonobo_lang.analysis.BonoboModule;
import org.bonobo_lang.frontend.BonoboLexer;
import org.bonobo_lang.frontend.BonoboParser;

import java.io.IOException;

/**
 * Hello world!
 */
public class MonkeyBusiness {
    public static void main(String[] args) throws IOException {
        if (args.length < 1) {
            System.err.println("fatal error: no input file");
        } else {
            // TODO: Options
            for (String filename : args) {
                CharStream charStream = CharStreams.fromFileName(filename);
                BonoboLexer lexer = new BonoboLexer(charStream);
                CommonTokenStream tokenStream = new CommonTokenStream(lexer);
                BonoboParser parser = new BonoboParser(tokenStream);
                BonoboParser.ProgContext prog = parser.prog();
                BonoboAnalyzer analyzer = new BonoboAnalyzer();
                BonoboModule module = analyzer.analyzeIdempotent(filename, prog);
                System.out.println(module.getScope().getSymbols().size());
            }
        }
    }
}