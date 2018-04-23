library bonobo.src.analysis;

import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:c_builder/c_builder.dart' as c;
import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:resource/resource.dart';
import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:ast/ast.dart';
import 'package:scanner/scanner.dart';
import 'package:parser/parser.dart';

part 'analyzer.dart';
part 'byte.dart';
part 'control_flow.dart';
part 'context.dart';
part 'function.dart';

part 'enum_type.dart';
part 'function_type.dart';
part 'struct_type.dart';

part 'num.dart';
part 'object.dart';
part 'module.dart';
part 'module_system.dart';
part 'runtime.dart';
part 'scope.dart';
part 'string.dart';
part 'tuple.dart';
part 'type.dart';

part 'typedef.dart';

part 'usage.dart';

part 'expression_analyzer.dart';
part 'function_analyzer.dart';
part 'statement_analyzer.dart';
part 'type_analyzer.dart';
