import '../ir/ir.dart' as ir;

abstract class BonoboCompiler<T> {
  T compile(ir.Module module);
}