import 'dart:async';
import 'dart:io' hide Directory, File, FileMode;
import 'dart:io' as io show File;
import 'package:args/command_runner.dart';
import 'package:ast/ast.dart';
import 'package:bonobo/bonobo.dart';
import 'package:charcode/charcode.dart';
import 'package:file/file.dart'
    show Directory, File, FileSystem, ForwardingFileSystem;
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:dart_language_server/dart_language_server.dart' as lsp;
import 'package:dart_language_server/src/protocol/language_server/interface.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/messages.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/wireformat.dart'
    as lsp;
import 'package:dart_language_server/dart_language_server.dart' as lsp;
import 'package:logging/logging.dart';
import 'package:parser/parser.dart';
import 'package:scanner/scanner.dart';
import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:tuple/tuple.dart';

class BonoboLanguageServer extends lsp.LanguageServer {
  static const Duration queueTime = const Duration(seconds: 10);
  final Map<Uri, List<Completer<File>>> _queue = {};
  final StreamController<lsp.Diagnostics> _diagnostics = new StreamController();
  final Map<BonoboFileSystem, BonoboModuleSystem> _moduleSystems = {};
  final Completer _onDone = new Completer();
  final StreamController<lsp.ApplyWorkspaceEditParams> _workspaceEdits =
      new StreamController();
  final Logger logger;

  BonoboLanguageServer(this.logger);

  static bool isAlphaNumOrUnderscore(int ch) {
    return ch == $underscore ||
        (ch >= $A && ch <= $Z) ||
        (ch >= $a && ch <= $z) ||
        (ch >= $0 && ch <= $9);
  }

  static int convertSeverity(BonoboErrorSeverity severity) {
    switch (severity) {
      case BonoboErrorSeverity.hint:
        return 4;
      case BonoboErrorSeverity.information:
        return 3;
      case BonoboErrorSeverity.warning:
        return 2;
      default:
        return 1;
    }
  }

  static lsp.Position convertLocation(SourceLocation location) {
    return new lsp.Position((b) {
      b
        ..line = location.line
        ..character = location.column;
    });
  }

  static lsp.Range convertSpan(FileSpan span) {
    return new lsp.Range((b) {
      b
        ..start = convertLocation(span.start)
        ..end = convertLocation(span.end);
    });
  }

  BonoboFileSystem findFileSystem(Uri uri) {
    // If a URI exists outside of all existing filesystems,
    // then it is likely from a different module.
    var fileSystems = _moduleSystems.keys;
    logger.fine('Searching for file system for $uri');

    for (var fileSystem in fileSystems) {
      logger.fine('Searching root: ${fileSystem.currentDirectory.path}');

      if (fileSystem.path.isWithin(
          fileSystem.currentDirectory.path, fileSystem.path.fromUri(uri))) {
        logger.fine('Found in: ${fileSystem.currentDirectory.path}');
        return fileSystem;
      }
    }

    return new BonoboFileSystem(const LocalFileSystem(), uri, this, logger);
  }

  Uri convertDocumentId(lsp.TextDocumentIdentifier documentId) {
    try {
      return Uri.parse(documentId.uri);
    } on FormatException {
      return findFileSystem(convertDocumentId(documentId))
          .file(documentId.uri)
          .absolute
          .uri;
    }
  }

  static String currentWord(String text, lsp.Position position) {
    var lines = text.split('\n');
    var line = lines[position.line];
    int start = position.character.clamp(0, line.length - 1), end = start;
    var ch = line.codeUnitAt(start);
    if (!isAlphaNumOrUnderscore(ch)) return null;

    for (int i = position.character - 1; i > 0; i--) {
      if (isAlphaNumOrUnderscore(line.codeUnitAt(i)))
        start = i;
      else
        break;
    }

    for (int i = position.character + 1; i < line.length; i++) {
      if (isAlphaNumOrUnderscore(line.codeUnitAt(i)))
        end = i;
      else
        break;
    }

    start = start.clamp(0, line.length - 1);
    end = end.clamp(0, line.length - 1);

    return line.substring(start, end + 1);
  }

  @override
  Stream<lsp.Diagnostics> get diagnostics => _diagnostics.stream;

  @override
  Stream<lsp.ApplyWorkspaceEditParams> get workspaceEdits =>
      _workspaceEdits.stream;

  Future<String> loadText(Uri uri) {
    return findFileSystem(uri).file(uri).readAsString();
  }

  Future<Tuple2<Parser, CompilationUnitContext>> parse(
      lsp.TextDocumentIdentifier documentId) {
    var uri = convertDocumentId(documentId);
    var fs = findFileSystem(uri);
    var file = fs.file(uri);

    if (!file.existsSync()) {
      // Create a fake, empty file, and parse it.
      file.createSync(recursive: true);
      file.writeAsStringSync('');

      // Force-read the file
      var realFile = const LocalFileSystem().file(uri);

      textDocumentDidOpen(new lsp.TextDocumentItem((b) {
        b
          ..uri = uri.toString()
          ..text = realFile.readAsStringSync();
      }));

      //throw new UnimplementedError('File does not exist (yet): ${file.uri}');

      /*var c = new Completer<File>();
      _queue.putIfAbsent(file.uri, () => []).add(c);
      return c.future.then(parseFile);.timeout(queueTime).catchError((_) {
        throw 'Analysis was requested for file "${file.uri}", but a textDocument/didOpen event was never sent.';
      });*/
    }

    return parseFile(file);
  }

  Future<Tuple2<Parser, CompilationUnitContext>> parseFile(File file,
      [bool analyze = false]) async {
    // Load the file...
    var contents = await file.readAsString();
    return parseText(contents, file.uri, analyze: analyze);
  }

  /// Currently the fastest implementation of (re-)parsing text in-memory.
  ///
  /// i.e. It guarantees only **one** pass over the text+AST.
  Tuple2<Parser, CompilationUnitContext> parseText(
      String contents, Uri sourceUrl,
      {bool analyze: false}) {
    // Clear existing diagnostics
    _diagnostics.add(new lsp.Diagnostics((b) {
      b
        ..uri = sourceUrl.toString()
        ..diagnostics = [];
    }));

    logger.fine('Re-parsing contents from $sourceUrl');

    // Load the file...
    var scanner = new Scanner(contents, sourceUrl: sourceUrl)..scan();
    var parser = new Parser(scanner),
        compilationUnit = parser.parseCompilationUnit();
    if (analyze == true) analyzeFromParser(parser, compilationUnit);
    return new Tuple2(parser, compilationUnit);
  }

  Future<BonoboAnalyzer> analyze(lsp.TextDocumentIdentifier documentId) async {
    var tuple = await parse(documentId);
    var sourceUrl = tuple.item1.scanner.scanner.sourceUrl;
    var contents =
        await findFileSystem(sourceUrl).file(sourceUrl).readAsString();
    return await analyzeText(contents, sourceUrl);
  }

  void sendErrors(Iterable<BonoboError> errors) {
    Map<Uri, List<lsp.Diagnostic>> diagnostics = {};

    for (var e in errors) {
      diagnostics
          .putIfAbsent(e.span.sourceUrl, () => [])
          .add(new lsp.Diagnostic((b) {
        b
          ..severity = convertSeverity(e.severity)
          ..range = convertSpan(e.span)
          ..message = e.message;
      }));
    }

    // Send all diagnostics, from their respective files
    diagnostics.forEach((uri, diagnostics) {
      _diagnostics.add(new lsp.Diagnostics((b) {
        b
          ..uri = uri.toString()
          ..diagnostics = diagnostics;
      }));
    });
  }

  Future<BonoboAnalyzer> analyzeText(String contents, Uri sourceUrl) async {
    var tuple = parseText(contents, sourceUrl);
    return await analyzeFromParser(tuple.item1, tuple.item2);
  }

  Future<BonoboAnalyzer> analyzeFromParser(
      Parser parser, CompilationUnitContext compilationUnit) async {
    var sourceUrl = parser.scanner.scanner.sourceUrl;
    var fileSystem = findFileSystem(sourceUrl);
    var moduleSystem = _moduleSystems[fileSystem] ??=
        await BonoboModuleSystem.create(fileSystem.file(sourceUrl).parent);
    moduleSystem?.rootModule?.compilationUnits?.remove(sourceUrl);

    // Find the existing analyzer
    logger.fine('Finding module for file: $sourceUrl');
    var module = await moduleSystem.findModuleForFile(
        sourceUrl, moduleSystem.rootModule);
    module.compilationUnits.remove(sourceUrl);
    await moduleSystem.analyzeModule(
        module, module.directory, moduleSystem.rootModule,
        fresh: true);
    var analyzer = module.analyzer;
    logger.fine('Analysis of $sourceUrl produced module "${module.name}"');

    /*
    var analyzer = new BonoboAnalyzer(
      compilationUnit,
      sourceUrl,
      parser,
      moduleSystem,
    );
    await analyzer.analyze();
    */

    sendErrors(analyzer.errors);
    return analyzer;
  }

  @override
  Future<lsp.ServerCapabilities> initialize(int clientPid, String rootUri,
      lsp.ClientCapabilities clientCapabilities, String trace) async {
    return new lsp.ServerCapabilities(
      (b) => b
        ..textDocumentSync = new lsp.TextDocumentSyncOptions((b) => b
          ..openClose = true
          ..change = lsp.TextDocumentSyncKind.full
          ..willSave = false
          ..willSaveWaitUntil = false
          ..save = new lsp.SaveOptions((b) {
            b..includeText = false;
          }))
        ..completionProvider = new lsp.CompletionOptions((b) => b
          ..resolveProvider = false
          ..triggerCharacters = const ['.'])
        ..codeActionProvider = false //true
        ..definitionProvider = true
        ..documentHighlightsProvider = true
        ..documentSymbolProvider = true
        ..hoverProvider = true
        ..referencesProvider = true
        ..renameProvider = true
        ..workspaceSymbolProvider = false
        ..codeLensProvider = new lsp.CodeLensOptions((b) {
          b..resolveProvider = false;
        })
        ..documentFormattingProvider = false
        ..documentRangeFormattingProvider = false
        ..documentOnTypeFormattingProvider =
            new lsp.DocumentOnTypeFormattingOptions((b) {
          b
            ..firstTriggerCharacter = '.'
            ..moreTriggerCharacter = ['::'];
        }),
    );
  }

  /// Figure which function the user is currently typing in.
  BonoboFunction currentFunction(
      BonoboAnalyzer analyzer, Uri sourceUrl, lsp.Position position) {
    for (var symbol in analyzer.module.scope.root.allPublicVariables) {
      if (symbol.value == null) continue;
      if (symbol.value is! BonoboFunction) continue;
      if (symbol.value.span == null) continue;
      if (symbol.value.span.sourceUrl != sourceUrl) continue;
      if (symbol.value.span.end.line < position.line) continue;
      if (symbol.value.span.start.line > position.line) continue;
      return symbol.value;
    }

    return null;
  }

  Future<Tuple3<BonoboAnalyzer, Variable<BonoboObject>, String>>
      currentSymbolAndAnalyzer(
          lsp.TextDocumentIdentifier documentId, lsp.Position position) async {
    var analyzer = await analyze(documentId);
    // TODO: Find current control flow within function?
    var sourceUrl = convertDocumentId(documentId);
    var function = currentFunction(analyzer, sourceUrl, position);
    if (function == null) return null;
    var contents = await loadText(sourceUrl);
    var name = currentWord(contents, position);
    if (name == null) return null;
    var variable = function.scope.resolve(name);
    return new Tuple3(analyzer, variable, name);
  }

  /// Resolves [currentWord] to a symbol within the current scope.
  Future<Variable<BonoboObject>> currentSymbol(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) async {
    var tuple = await currentSymbolAndAnalyzer(documentId, position);
    return tuple?.item2;
  }

  /// Fetch all usages of the current symbol, or an empty `List` (`[]`).
  Future<List<SymbolUsage>> currentUsages(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) async {
    var symbol = await currentSymbol(documentId, position);
    return symbol?.value?.usages ?? [];
  }

  lsp.Location currentLocation(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) {
    return new lsp.Location((b) {
      b
        ..uri = convertDocumentId(documentId).toString()
        ..range = new lsp.Range((b) {
          b
            ..start = position
            ..end = position;
        });
    });
  }

  @override
  Future<lsp.WorkspaceEdit> textDocumentRename(
      lsp.TextDocumentIdentifier documentId,
      lsp.Position position,
      String newName) async {
    var usages = await currentUsages(documentId, position);
    return new lsp.WorkspaceEdit((b) {
      b.changes = {};

      for (var usage in usages) {
        b.changes
            .putIfAbsent(usage.span.sourceUrl.toString(), () => [])
            .add(new lsp.TextEdit((b) {
          b
            ..newText = newName
            ..range = convertSpan(usage.span);
        }));
      }
    });
  }

  @override
  Future<Null> workspaceExecuteCommand(String command) async {}

  @override
  Future<List<lsp.Command>> textDocumentCodeAction(
      lsp.TextDocumentIdentifier documentId,
      lsp.Range range,
      lsp.CodeActionContext context) async {
    var analyzer = await analyze(documentId);
    return [];
  }

  @override
  Future<lsp.Hover> textDocumentHover(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) async {
    var tuple = await currentSymbolAndAnalyzer(documentId, position);
    var analyzer = tuple?.item1, symbol = tuple?.item2, name = tuple?.item3;

    if (symbol?.value?.span != null) {
      var value = symbol.value;
      return new lsp.Hover((b) {
        var type =
            value is BonoboFunction ? value.type.signature : value.type.name;
        b
          ..contents = '${symbol.name}: $type'
          ..range = convertSpan(value.span);
      });
    } else if (analyzer?.module?.types?.containsKey(name) == true) {
      // TODO: Find types with prefixes, etc.
      var type = analyzer.module.types[name];

      return new lsp.Hover((b) {
        b
          ..contents = type.documentation.isNotEmpty
              ? type.documentation
              : 'Type: ${type.name}';
        // TODO: Get declaration of types?
      });
    } else {
      return null;
    }
  }

  @override
  Future<List<lsp.SymbolInformation>> textDocumentSymbols(
      lsp.TextDocumentIdentifier documentId) async {
    //var analyzer = await analyze(documentId);
    var analyzer = await analyze(documentId);

    void listAll(List<lsp.SymbolInformation> info,
        SymbolTable<BonoboObject> scope, BonoboModule module) {
      for (var symbol in scope.allVariables) {
        if (symbol.value?.span == null) continue;
        var value = symbol.value;

        info.add(new lsp.SymbolInformation((b) {
          b
            ..name = symbol.name
            ..containerName = module.fullName
            ..kind = lsp.SymbolKind.variable
            ..location = new lsp.Location((b) {
              b
                ..uri = symbol.value.span.sourceUrl.toString()
                ..range = convertSpan(symbol.value.span);
            });

          if (value is BonoboFunction) {
            b
              ..name = '${value.name}(${value.parameters.map((p) => p.name)
                  .join(
                  ', ')})'
              ..kind = lsp.SymbolKind.function;
          }
        }));
      }
    }

    void listModule(BonoboModule module, List<lsp.SymbolInformation> info) {
      logger
          .fine('Listing symbols from module ${module.name} (children: ${module
          .children.map((m) => m.name)})');

      if (module.compilationUnits.isNotEmpty) {
        var firstKey = module.compilationUnits.keys.first;
        var span = module.compilationUnits[firstKey].span;

        info.add(new lsp.SymbolInformation((b) {
          b
            ..name = module.name
            ..kind = lsp.SymbolKind.package
            ..containerName = module.parent?.fullName?.isNotEmpty == true
                ? module.parent.fullName
                : '<root>'
            ..location = new lsp.Location((b) {
              b
                ..uri = span.sourceUrl.toString()
                ..range = convertSpan(span);
            });
        }));
      }

      listAll(info, module.scope.root, module);

      for (var name in module.types.keys) {
        var type = module.types[name];
        info.add(new lsp.SymbolInformation((b) {
          b
            ..name = name
            ..kind = lsp.SymbolKind.interface
            ..containerName = module.fullName
            ..location = new lsp.Location((b) {
              b
                ..uri = type.span.sourceUrl.toString()
                ..range = convertSpan(type.span);
            });
        }));
      }

      var subInfo = <lsp.SymbolInformation>[];
      for (var child in module.children) listModule(child, subInfo);
      info.addAll(subInfo);

      logger.fine('Info from ${module.name}');
      info.forEach((b) {
        logger.fine('* ${b.toJson()}');
      });
      module.moduleSystem.dumpTree(module);
    }

    var info = <lsp.SymbolInformation>[];
    listModule(analyzer.module, info);
    return info;
  }

  @override
  Future<List<lsp.DocumentHighlight>> textDocumentHighlights(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) async {
    var usages = await currentUsages(documentId, position);
    return usages.map((usage) {
      return new lsp.DocumentHighlight((b) {
        b
          ..kind = usage.type == SymbolUsageType.read
              ? lsp.DocumentHighlightKind.read
              : lsp.DocumentHighlightKind.write
          ..range = convertSpan(usage.span);
      });
    }).toList();
  }

  @override
  Future<List<lsp.Location>> textDocumentReferences(
      lsp.TextDocumentIdentifier documentId,
      lsp.Position position,
      lsp.ReferenceContext context) async {
    var usages = await currentUsages(documentId, position);
    return usages.map((usage) {
      return new lsp.Location((b) {
        b
          ..uri = usage.span.sourceUrl.toString()
          ..range = convertSpan(usage.span);
      });
    }).toList();
  }

  @override
  Future<lsp.Location> textDocumentDefinition(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) async {
    var symbol = await currentSymbol(documentId, position);
    if (symbol?.value == null) return null;
    return new lsp.Location((b) {
      b
        ..uri = symbol.value.span.sourceUrl.toString()
        ..range = convertSpan(symbol.value.span);
    });
  }

  @override
  Future<lsp.CompletionList> textDocumentCompletion(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) async {
    var analyzer = await analyze(documentId);
    var uri = convertDocumentId(documentId);
    var function = currentFunction(analyzer, uri, position);
    var items = <lsp.CompletionItem>[];

    // TODO: Snippets?

    List<Variable<BonoboObject>> scope =
        (function?.scope ?? analyzer.module.scope.root).allVariables;

    analyzer.module.types.forEach((name, type) {
      // TODO: Get ALL types
      items.add(new lsp.CompletionItem((b) {
        b
          ..label = name
          ..kind = lsp.CompletionItemKind.classKind
          ..detail = type.documentation;
      }));
    });

    for (var symbol in scope) {
      if (symbol.value != null) {
        items.add(new lsp.CompletionItem((b) {
          b
            ..label = symbol.name
            ..kind = lsp.CompletionItemKind.variable;

          if (symbol.value is BonoboFunction) {
            var f = (symbol.value as BonoboFunction);
            var insertText = new StringBuffer('${f.name}(');

            for (int i = 0; i < f.parameters.length; i++) {
              var p = f.parameters[i];

              if (i > 0) insertText.write(', ');
              insertText.write('\${${i + 1}:${p.name}}');
            }

            insertText.write(')');

            b
              ..kind = lsp.CompletionItemKind.function
              ..detail = f.type.signature
              ..documentation = f.documentation
              ..insertTextFormat = lsp.InsertTextFormat.snippet
              ..textEdit = new lsp.TextEdit((b) {
                b
                  ..newText = insertText.toString()
                  ..range = new lsp.Range((b) {
                    b
                      ..start = new lsp.Position((b) {
                        b
                          ..line = position.line
                          ..character = position.character - 1;
                      })
                      ..end = new lsp.Position((b) {
                        b
                          ..line = position.line
                          ..character = position.character + insertText.length;
                      });
                  });
              });
          } else {
            b.detail = symbol.value.type.name;
          }
        }));
      }
    }

    return new lsp.CompletionList((b) {
      b
        ..isIncomplete = false
        ..items = items;
    });
  }

  @override
  textDocumentDidOpen(lsp.TextDocumentItem document) async {
    var sourceUrl = Uri.parse(document.uri);

    var file = findFileSystem(sourceUrl).file(sourceUrl);
    if (!await file.exists()) {
      await file.create(recursive: true);
      _queue[file.uri]?.forEach((c) => c.complete(file));
    }

    await file.writeAsString(document.text);
    parseText(document.text, sourceUrl, analyze: true);
  }

  @override
  void textDocumentDidChange(lsp.VersionedTextDocumentIdentifier documentId,
      List<lsp.TextDocumentContentChangeEvent> changes) {
    if (changes.isEmpty) return;

    var sourceUrl = Uri.parse(documentId.uri);
    var textOnly = !changes.any((c) => c.range != null);
    var file = findFileSystem(sourceUrl).file(sourceUrl);

    if (textOnly) {
      file.create(recursive: true).then((_) async {
        await file.writeAsString(changes.last.text);
        //_queue[file.uri]?.forEach((c) => c.complete(file));
        parseText(changes.last.text, sourceUrl, analyze: true);
      });
      return;
    }

    scheduleMicrotask(() async {
      for (var change in changes) {
        var contents = await file.readAsString();

        int findIndex(lsp.Position position) {
          var lines = contents.split('\n');

          // Sum the length of the previous lines.
          int lineLength = lines
              .take(position.line - 1)
              .map((s) => s.length)
              .reduce((a, b) => a + b);
          return lineLength + position.character - 1;
        }

        if (change.range == null) {
          contents = change.text;
        } else {
          var start = findIndex(change.range.start),
              end = findIndex(change.range.end);
          contents = contents.replaceRange(start, end, change.text);
        }

        await file.writeAsString(contents);
        //_queue[file.uri]?.forEach((c) => c.complete(file));
      }

      parseFile(file, true);
    });
  }

  @override
  Future<Null> get onDone {
    return _onDone.future;
  }

  @override
  void textDocumentDidClose(lsp.TextDocumentIdentifier documentId) {
    var file = findFileSystem(convertDocumentId(documentId))
        .file(convertDocumentId(documentId));
    file.delete(recursive: true).catchError((_) => null);
  }

  @override
  Future<List<lsp.Location>> textDocumentImplementation(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) {
    // TODO: implement textDocumentImplementation
  }

  @override
  Future<List<lsp.SymbolInformation>> workspaceSymbol(String query) {
    // TODO: implement workspaceSymbol
  }
}
