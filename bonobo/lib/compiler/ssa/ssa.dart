library bonobo.compiler.ssa;

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:linear_memory/linear_memory.dart';
import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:tuple/tuple.dart';
import '../../analysis/analysis.dart';
import '../../ast/ast.dart';
import '../../scanner/scanner.dart';
import '../../util/util.dart';
import '../bvm/bvm.dart';

part 'block.dart';
part 'bytecode_generator.dart';
part 'compiler.dart';
part 'dominance.dart';
part 'instruction.dart';
part 'procedure.dart';
part 'program.dart';
part 'register.dart';