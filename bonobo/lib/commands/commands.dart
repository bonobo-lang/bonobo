library bonobo.src.commands;

import 'dart:async';
import 'dart:convert';
import 'dart:io' hide Directory, File, FileMode;
import 'dart:io' as io show File;
import 'package:args/command_runner.dart';

import 'package:code_buffer/code_buffer.dart';
import 'package:file/local.dart';
import 'package:tuple/tuple.dart';
import 'package:bonobo/bonobo.dart';

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
