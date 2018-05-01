part of bonobo.compiler.ssa;

abstract class Instruction {
  FileSpan get span;
  DominanceFrontier get dominanceFrontier;
  int get size;

  int get totalSize => size + dominanceFrontier.size;
}