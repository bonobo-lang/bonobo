package org.bonobo_lang;

import org.antlr.v4.runtime.*;
import org.bonobo_lang.BonoboLexer;
import org.bonobo_lang.BonoboParser;

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
            for (String filename: args) {
                CharStream charStream = CharStreams.fromFileName(filename);
                BonoboLexer lexer = new BonoboLexer(charStream);
                CommonTokenStream tokenStream = new CommonTokenStream(lexer);
                BonoboParser parser = new BonoboParser(tokenStream);
                BonoboParser.ProgContext prog = parser.prog();
            }
        }
    }
}