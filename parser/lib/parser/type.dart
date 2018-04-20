part of 'parser.dart';

class TypeParser {
  final BonoboParseState state;

  TypeParser(this.state);

  TypeContext parse() {
    IdentifierContext id = state.nextId();
    if(id == null) return null;
  }
}