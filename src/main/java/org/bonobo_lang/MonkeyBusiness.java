package org.bonobo_lang;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.apache.commons.cli.*;
import org.bonobo_lang.analysis.BonoboAnalyzer;
import org.bonobo_lang.analysis.BonoboError;
import org.bonobo_lang.analysis.BonoboModule;
import org.bonobo_lang.analysis.SourceLocation;
import org.bonobo_lang.backend.llvm.LlvmBackend;
import org.bonobo_lang.banana.BananaModule;
import org.bonobo_lang.banana.BananaPass;
import org.bonobo_lang.frontend.BonoboLexer;
import org.bonobo_lang.frontend.BonoboParser;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

public class MonkeyBusiness {
    public static void main(String[] args) {
        Options options = new Options()
                .addOption("c", false, "Only compile; do not link.")
                .addOption("g", false, "Include debug symbols.")
                .addOption("h", "help", false, "Print this help information.")
                .addOption("o", "out", true, "Specify an output name to write to.")
                .addOption("f", "emit", true, "The type of output to produce.")
                .addOption("O", true, "Optimization level (default -O2)");

        Option linkFileOption = new Option("l", true, "Link a library.");
        Option linkDirectoryOption = new Option("L", true, "Link a directory containing libraries.");
        linkFileOption.setArgs(Option.UNLIMITED_VALUES);
        linkDirectoryOption.setArgs(Option.UNLIMITED_VALUES);
        options.addOption(linkFileOption);
        options.addOption(linkDirectoryOption);

        try {
            CommandLine cmd = new DefaultParser().parse(options, args);
            List<String> argList = cmd.getArgList();
            Runtime rt = Runtime.getRuntime();

            if (cmd.hasOption("h")) {
                new HelpFormatter().printHelp("bonobo [options...] [<files>]", options);
                return;
            }


            if (argList.isEmpty()) {
                System.err.println("fatal error: no input file");
                System.exit(64);
            } else {
                if (!cmd.hasOption("c")) {
                    List<String> ccArgs = new ArrayList<>();
                    ccArgs.add("env");
                    ccArgs.add("cc");
                    if (cmd.hasOption("l")) for (String name : cmd.getOptionValues("l")) ccArgs.add("-l" + name);
                    if (cmd.hasOption("L")) for (String name : cmd.getOptionValues("L")) ccArgs.add("-L" + name);
                    ccArgs.add("-o");
                    ccArgs.add(cmd.getOptionValue("o", "a.out"));
                    ccArgs.addAll(argList);
                    Process cc = rt.exec(ccArgs.toArray(new String[0]));
                    handleProcess(cc);
                } else {
                    String emit = cmd.getOptionValue("emit", "obj");

                    if (cmd.hasOption("o") && argList.size() > 1) {
                        throw new ParseException("cannot use the -o flag when generating multiple output files");
                    }

                    BonoboAnalyzer analyzer = new BonoboAnalyzer();

                    for (String filename : argList) {
                        String outputFilename;
                        analyzer.getErrors().clear();

                        if (argList.size() == 1 && cmd.hasOption("o")) {
                            outputFilename = cmd.getOptionValue("o");
                        } else {
                            String extension = ".o";
                            if (emit.equals("llvm"))
                                extension = ".ll";
                            else if (emit.equals("asm"))
                                extension = ".s";
                            outputFilename = filename.replaceFirst("(\\.\\w+)?$", extension);
                        }

                        CharStream charStream = CharStreams.fromFileName(filename);
                        BonoboLexer lexer = new BonoboLexer(charStream);
                        lexer.removeErrorListeners();
                        lexer.addErrorListener(analyzer);
                        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
                        BonoboParser parser = new BonoboParser(tokenStream);
                        parser.removeErrorListeners();
                        parser.addErrorListener(analyzer);
                        BonoboParser.ProgContext prog = parser.prog();
                        BonoboModule module = analyzer.analyzeIdempotent(filename, prog);

                        // Find all errors
                        boolean anyWasError = false;
                        for (BonoboError error : analyzer.getErrors()) {
                            SourceLocation location = error.getLocation();
                            anyWasError |= error.getSeverity() == BonoboError.Severity.error;
                            // TODO: severity to string
                            if (System.console() != null) {
                                System.err.printf("\u001b[1m%s:%d:%d: \u001b[31m%s:\u001b[0m\u001b[1m %s\u001b[0m%n",
                                        location.getSourceUrl(), location.getLine(), location.getColumn(),
                                        "error", error.getMessage()
                                );
                            } else {
                                System.err.printf("%s:%d:%d: %s: %s%n",
                                        location.getSourceUrl(), location.getLine(), location.getColumn(),
                                        "error", error.getMessage()
                                );
                            }
                        }

                        if (anyWasError) {
                            System.exit(1);
                            return;
                        }

                        BananaPass bananaPass = new BananaPass(analyzer, module);
                        bananaPass.run();
                        BananaModule bananaModule = bananaPass.getBananaModule();
                        LlvmBackend llvmBackend = new LlvmBackend(bananaModule);
                        llvmBackend.compile();

                        if (emit.equals("llvm")) {
                            PrintStream out = new PrintStream(outputFilename);
                            out.println(llvmBackend.getStringBuilder());
                            out.close();
                            continue;
                        }

                        // Generating either asm or obj
                        List<String> llcArgs = new ArrayList<>();
                        llcArgs.add("env");
                        llcArgs.add("llc");
                        llcArgs.add("-O" + cmd.getOptionValue("O", "2"));
                        llcArgs.add("-filetype");
                        llcArgs.add(emit);
                        llcArgs.add("-o");
                        llcArgs.add(outputFilename);
                        String[] llcArgArray = llcArgs.toArray(new String[0]);
                        Process llc = rt.exec(llcArgArray);
                        PrintStream llcIn = new PrintStream(llc.getOutputStream());
                        llcIn.println(llvmBackend.getStringBuilder());
                        //llcIn.flush();
                        llcIn.close();
                        handleProcess(llc);
                    }
                }

            }
        } catch (ParseException exc) {
            System.err.printf("fatal error: %s%n", exc.getMessage());
            new HelpFormatter().printHelp("bonobo [options...] [<files>]", options);
            System.exit(64);
        } catch (Exception exc) {
            System.err.printf("fatal error: %s%n", exc.getMessage());
            exc.printStackTrace(System.err);
            System.exit(1);
        }
    }

    private static void handleProcess(Process llc) throws IOException, InterruptedException {
        llc.waitFor();
        InputStream input;

        if (llc.exitValue() != 0) {
            input = llc.getErrorStream();
        } else {
            input = llc.getInputStream();
        }

        InputStreamReader errReader = new InputStreamReader(input);
        int ch = errReader.read();
        while (ch != -1) {
            System.err.write(ch);
            ch = errReader.read();
        }

        if (llc.exitValue() != 0) {
            System.exit(llc.exitValue());
        }
    }
}