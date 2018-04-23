// GENERATED CODE - DO NOT MODIFY BY HAND

part of bonobo.compiler.ll;

// **************************************************************************
// Generator: JsonModelGenerator
// **************************************************************************

class CompilationUnit extends _CompilationUnit {
  CompilationUnit({this.typedefs, this.enums, this.functions});

  @override
  final List<_Typedef> typedefs;

  @override
  final List<_Enum> enums;

  @override
  final List<_FunctionLL> functions;

  CompilationUnit copyWith(
      {List<_Typedef> typedefs,
      List<_Enum> enums,
      List<_FunctionLL> functions}) {
    return new CompilationUnit(
        typedefs: typedefs ?? this.typedefs,
        enums: enums ?? this.enums,
        functions: functions ?? this.functions);
  }

  Map<String, dynamic> toJson() {
    return CompilationUnitSerializer.toMap(this);
  }
}

class Typedef extends _Typedef {
  Typedef({this.name, this.type});

  @override
  final String name;

  @override
  final _Type type;

  Typedef copyWith({String name, _Type type}) {
    return new Typedef(name: name ?? this.name, type: type ?? this.type);
  }

  Map<String, dynamic> toJson() {
    return TypedefSerializer.toMap(this);
  }
}

class Enum extends _Enum {
  Enum({this.name, this.values});

  @override
  final String name;

  @override
  final List<String> values;

  Enum copyWith({String name, List<String> values}) {
    return new Enum(name: name ?? this.name, values: values ?? this.values);
  }

  Map<String, dynamic> toJson() {
    return EnumSerializer.toMap(this);
  }
}

class FunctionLL extends _FunctionLL {
  FunctionLL({this.name, this.parameters, this.returnType, this.body});

  @override
  final String name;

  @override
  final List<_Parameter> parameters;

  @override
  final _Type returnType;

  @override
  final List<_Statement> body;

  FunctionLL copyWith(
      {String name,
      List<_Parameter> parameters,
      _Type returnType,
      List<_Statement> body}) {
    return new FunctionLL(
        name: name ?? this.name,
        parameters: parameters ?? this.parameters,
        returnType: returnType ?? this.returnType,
        body: body ?? this.body);
  }

  Map<String, dynamic> toJson() {
    return FunctionLLSerializer.toMap(this);
  }
}

class Parameter extends _Parameter {
  Parameter({this.name, this.type});

  @override
  final String name;

  @override
  final _Type type;

  Parameter copyWith({String name, _Type type}) {
    return new Parameter(name: name ?? this.name, type: type ?? this.type);
  }

  Map<String, dynamic> toJson() {
    return ParameterSerializer.toMap(this);
  }
}

class Statement extends _Statement {
  Statement({this.expression});

  @override
  final _ExpressionStatement expression;

  Statement copyWith({_ExpressionStatement expression}) {
    return new Statement(expression: expression ?? this.expression);
  }

  Map<String, dynamic> toJson() {
    return StatementSerializer.toMap(this);
  }
}

class ExpressionStatement extends _ExpressionStatement {
  ExpressionStatement({this.isReturn});

  @override
  final bool isReturn;

  ExpressionStatement copyWith({bool isReturn}) {
    return new ExpressionStatement(isReturn: isReturn ?? this.isReturn);
  }

  Map<String, dynamic> toJson() {
    return ExpressionStatementSerializer.toMap(this);
  }
}

class Struct extends _Struct {
  Struct({this.name, this.fields});

  @override
  final String name;

  @override
  final List<_Field> fields;

  Struct copyWith({String name, List<_Field> fields}) {
    return new Struct(name: name ?? this.name, fields: fields ?? this.fields);
  }

  Map<String, dynamic> toJson() {
    return StructSerializer.toMap(this);
  }
}

class Field extends _Field {
  Field({this.name, this.type});

  @override
  final String name;

  @override
  final _Type type;

  Field copyWith({String name, _Type type}) {
    return new Field(name: name ?? this.name, type: type ?? this.type);
  }

  Map<String, dynamic> toJson() {
    return FieldSerializer.toMap(this);
  }
}

class Type extends _Type {
  Type({this.name, this.pointer, this.array});

  @override
  final String name;

  @override
  final _PointerType pointer;

  @override
  final _ArrayType array;

  Type copyWith({String name, _PointerType pointer, _ArrayType array}) {
    return new Type(
        name: name ?? this.name,
        pointer: pointer ?? this.pointer,
        array: array ?? this.array);
  }

  Map<String, dynamic> toJson() {
    return TypeSerializer.toMap(this);
  }
}

class PointerType extends _PointerType {
  PointerType({this.inner});

  @override
  final _Type inner;

  PointerType copyWith({_Type inner}) {
    return new PointerType(inner: inner ?? this.inner);
  }

  Map<String, dynamic> toJson() {
    return PointerTypeSerializer.toMap(this);
  }
}

class ArrayType extends _ArrayType {
  ArrayType({this.inner, this.size});

  @override
  final _Type inner;

  @override
  final int size;

  ArrayType copyWith({_Type inner, int size}) {
    return new ArrayType(inner: inner ?? this.inner, size: size ?? this.size);
  }

  Map<String, dynamic> toJson() {
    return ArrayTypeSerializer.toMap(this);
  }
}
