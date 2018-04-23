library bonobo.src.commands;

import 'dart:async';
import 'dart:io' hide Directory, File, FileMode;
import 'dart:io' as io show Directory, File;
import 'package:args/command_runner.dart';

import 'package:charcode/charcode.dart';
import 'package:code_buffer/code_buffer.dart';
import 'package:dart_language_server/src/protocol/language_server/interface.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/messages.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/wireformat.dart'
    as lsp;
import 'package:dart_language_server/dart_language_server.dart' as lsp;
import 'package:file/file.dart'
    show Directory, File, FileSystem, ForwardingFileSystem;
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:source_span/source_span.dart';
import 'package:tuple/tuple.dart';
import 'package:bonobo/analysis/analysis.dart';
import 'package:bonobo/compiler/compiler.dart';
import 'package:c_builder/c_builder.dart' as c;
import '../ast/ast.dart';
import '../scanner/scanner.dart';
import '../parser/parser.dart';
import '../language_server/language_server.dart';

part 'bonobo_command.dart';

part 'compile.dart';

part 'document.dart';

part 'info.dart';

part 'explore.dart';

part 'file_system.dart';

part 'format.dart';

part 'language_server.dart';

part 'util.dart';

final CommandRunner commandRunner =
    new CommandRunner('bonobo', 'Command-line tools for the Bonobo language.')
      ..addCommand(new CompileCommand())
      ..addCommand(new DocumentCommand())
      ..addCommand(new ExploreCommand())
      ..addCommand(new FormatCommand())
      ..addCommand(new InfoCommand())
      ..addCommand(new LanguageServerCommand());
