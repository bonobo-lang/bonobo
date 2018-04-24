import 'package:bonobo/analysis/analysis.dart';
//import '../ir/ir.dart' as ir;

abstract class BonoboCompiler<T> {
  T compile(BonoboModule module);
}