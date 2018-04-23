/// A compact representation of Bonobo code that is less difficult to compile to multiple backends.
library bonobo.ir;

import 'package:angel_serialize/angel_serialize.dart';

part 'ir.g.dart';
part 'ir.serializer.g.dart';

part 'expression.dart';
part 'module.dart';
part 'misc.dart';
part 'statement.dart';
part 'type.dart';