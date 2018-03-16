library bonobo.src.commands;

import 'dart:async';
import 'dart:convert';
import 'dart:io' hide File;
import 'dart:io' as io show File;
import 'package:args/command_runner.dart';
import 'package:c_builder/c_builder.dart' as c;
import 'package:charcode/charcode.dart';
import 'package:code_buffer/code_buffer.dart';
import 'package:dart_language_server/src/protocol/language_server/interface.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/messages.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/wireformat.dart'
    as lsp;
import 'package:dart_language_server/dart_language_server.dart' as lsp;
import 'package:file/file.dart' show File, FileSystem, ForwardingFileSystem;
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' as p;
import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:tuple/tuple.dart';
import '../analysis/analysis.dart';
import '../ast/ast.dart';
import '../text/text.dart';

part 'format/replace.dart';

part 'bonobo_command.dart';

part 'compile.dart';

part 'compiler.dart';

part 'document.dart';

part 'file_system.dart';

part 'format.dart';

part 'language_server.dart';

part 'util.dart';

final CommandRunner commandRunner =
    new CommandRunner('bonobo', 'Command-line tools for the Bonobo language.')
      ..addCommand(new CompileCommand())
      ..addCommand(new DocumentCommand())
      ..addCommand(new FormatCommand())
      ..addCommand(new LanguageServerCommand());
