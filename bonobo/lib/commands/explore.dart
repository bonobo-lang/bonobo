part of bonobo.src.commands;

class ExploreCommand extends Command {
  String get name => 'explore';

  String get description =>
      'An interactive interface for exploring Bonobo AST\'s.';

  bool initialized = false;
  BonoboAnalyzer analyzer;

  @override
  run() async {
    analyzer = await analyze(this);

    var errors =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.error);
    var warnings =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.warning);

    printErrors(errors);
    printErrors(warnings);

    var repl = new _Repl();

    while (true) {
      var source = await repl.run().join('\n');
      var scanner = new Scanner(source, sourceUrl: 'stdin')..scan();

      var errors =
          scanner.errors.where((e) => e.severity == BonoboErrorSeverity.error);
      var warnings = scanner.errors
          .where((e) => e.severity == BonoboErrorSeverity.warning);
      printErrors(errors);
      printErrors(warnings);
      if (errors.isNotEmpty) continue;

      var parser = new Parser(scanner);
      var parsed = parser.parseFunction() ??
          parser.statementParser.variableDeclarationParser.parse() ??
          parser.statementParser.parseExpressionStatement() ??
          parser.parseSimpleIdentifier();

      errors =
          parser.errors.where((e) => e.severity == BonoboErrorSeverity.error);
      warnings =
          parser.errors.where((e) => e.severity == BonoboErrorSeverity.warning);
      printErrors(errors);
      printErrors(warnings);

      if (errors.isNotEmpty) continue;

      if (parsed == null && parser.peek()?.type == TokenType.identifier) {
        parsed = parser.parseSimpleIdentifier();
      }

      if (parsed == null) {
        continue;
      }

      if (!initialized) {
        analyzer.module.scope
          ..create(
            'ROOT',
            value: new _ModuleObject(
                analyzer.moduleSystem.rootModule, scanner.emptySpan),
            constant: true,
          )
          ..create(
            'MODULE',
            value: new _ModuleObject(analyzer.module, scanner.emptySpan),
            constant: true,
          );

        initialized = true;
      }

      if (parsed is VariableDeclarationStatementContext) {
        for (var decl in parsed.declarations) {
          var expr = await analyzer.expressionAnalyzer
              .resolve(decl.initializer, null, analyzer.module.scope);
          analyzer.module.scope.create(decl.name.name,
              value: expr,
              constant: decl.mutability >= VariableMutability.final_);
        }
      } else if (parsed is ExpressionContext) {
        var expr = await analyzer.expressionAnalyzer
            .resolve(parsed, null, analyzer.module.scope);

        errors = analyzer.errors
            .where((e) => e.severity == BonoboErrorSeverity.error);
        warnings = analyzer.errors
            .where((e) => e.severity == BonoboErrorSeverity.warning);
        printErrors(errors);
        printErrors(warnings);

        if (errors.isEmpty) {
          if (expr.type == BonoboType.Root)
            print('<unknown>');
          else
            print(expr);
          if (expr.span != null && expr.span.length > 0)
            print(expr.span.highlight());
        }
      }

      analyzer.errors.clear();
    }
  }
}

class _Repl {
  bool promptOn = true, submitted = false;
  int index = 0;
  List<StringBuffer> history = [new StringBuffer()];

  Stream<String> run() {
    var ctrl = new StreamController();
    scheduleMicrotask(() {
      var b = new StringBuffer();
      stdout.write('bonobo> ');

      while (true) {
        var line = stdin.readLineSync();
        if (!line.endsWith('\\')) {
          b.writeln(line);
          break;
        } else {
          b.writeln(line.substring(0, line.length - 1));
        }
      }

      ctrl.add(b.toString());
      ctrl.close();
    });
    return ctrl.stream;
  }

  Stream<String> runRL() {
    var ctrl = new StreamController();
    submitted = false;
    scheduleMicrotask(() async {
      bool newline = true;

      //if (false)
      stdin
        ..echoMode = false
        ..lineMode = false;

      void prompt() {
        stdout.writeCharCode($cr);
        if (promptOn) stdout.write('bonobo> ');
        stdout.write(history[index]);
      }

      void submit() {
        var line = history[index].toString();

        if (!line.endsWith('\\')) {
          ctrl.add(line);
          submitted = true;
          index++;
          if (index >= history.length) history.add(new StringBuffer());
          stdout.writeln();
          newline = true;
        } else {
          ctrl.add(line.substring(0, line.length - 1));
        }
      }

      prompt();
      while (true) {
        var b = history[index];
        var ch = stdin.readByteSync();

        if (ch == $esc) {
          ch = stdin.readByteSync();

          if (ch != $open_bracket) {
            ch = stdin.readByteSync();
            b..writeCharCode($esc)..writeCharCode(ch);
          } else {
            ch = stdin.readByteSync();

            if (ch == $A) {
              index = (index - 1).clamp(0, history.length - 1);
            } else if (ch == $B) {
              index = (index + 1).clamp(0, history.length);
              if (index >= history.length) {
                if (b.isEmpty)
                  index = history.length - 1;
                else
                  history.add(new StringBuffer());
              }
            } else if (ch == $C) {} else {
              var esc = new String.fromCharCode(ch);
              throw 'Unsupported escape: "$esc"';
            }
          }
        } else if (ch == $cr) {
          ch = stdin.readByteSync();
          if (ch == $lf) {
            submit();
          } else {
            b..writeCharCode($cr)..writeCharCode(ch);
          }
        } else if (ch == $lf || ch == 13) {
          submit();
        } else {
          b.writeCharCode(ch);
        }

        prompt();

        if (submitted) break;
      }
    });

    return ctrl.stream;
  }
}

class _ModuleObject extends BonoboObject {
  final BonoboModule module;

  _ModuleObject(this.module, FileSpan span)
      : super(new _ModuleType(module), span);

  @override
  String toString() {
    var b = new CodeBuffer();
    b..writeln('Module: ${module.name}');
    return b.toString();
  }
}

class _ModuleType extends BonoboType {
  final BonoboModule module;

  _ModuleType(this.module) {
    // Add child modules
    for (var child in module.children) {
      // TODO: Add fields
    }

    // Add all members
  }

  @override
  c.CType get ctype => null;

  @override
  bool get isRoot => false;

  @override
  String get name => '[module]';

  @override
  BonoboType get parent => BonoboType.Root;
}
