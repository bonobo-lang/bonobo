// GENERATED CODE - DO NOT MODIFY BY HAND

part of bonobo.ir;

// **************************************************************************
// Generator: JsonModelGenerator
// **************************************************************************

class Identifier extends _Identifier {
  Identifier({this.namespaces, this.name});

  @override
  final List<String> namespaces;

  @override
  final String name;

  Identifier copyWith({List<String> namespaces, String name}) {
    return new Identifier(
        namespaces: namespaces ?? this.namespaces, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() {
    return IdentifierSerializer.toMap(this);
  }
}

class Expression extends _Expression {
  Expression(
      {this.span,
      this.literal,
      this.identifier,
      this.binary,
      this.object,
      this.tuple});

  @override
  final _Span span;

  @override
  final dynamic literal;

  @override
  final _Identifier identifier;

  @override
  final _BinaryExpression binary;

  @override
  final _ObjectExpression object;

  @override
  final _TupleExpression tuple;

  Expression copyWith(
      {_Span span,
      dynamic literal,
      _Identifier identifier,
      _BinaryExpression binary,
      _ObjectExpression object,
      _TupleExpression tuple}) {
    return new Expression(
        span: span ?? this.span,
        literal: literal ?? this.literal,
        identifier: identifier ?? this.identifier,
        binary: binary ?? this.binary,
        object: object ?? this.object,
        tuple: tuple ?? this.tuple);
  }

  Map<String, dynamic> toJson() {
    return ExpressionSerializer.toMap(this);
  }
}

class BinaryExpression extends _BinaryExpression {
  BinaryExpression({this.left, this.right, this.op});

  @override
  final _Expression left;

  @override
  final _Expression right;

  @override
  final String op;

  BinaryExpression copyWith({_Expression left, _Expression right, String op}) {
    return new BinaryExpression(
        left: left ?? this.left, right: right ?? this.right, op: op ?? this.op);
  }

  Map<String, dynamic> toJson() {
    return BinaryExpressionSerializer.toMap(this);
  }
}

class TupleExpression extends _TupleExpression {
  TupleExpression({this.items});

  @override
  final List<_Expression> items;

  TupleExpression copyWith({List<_Expression> items}) {
    return new TupleExpression(items: items ?? this.items);
  }

  Map<String, dynamic> toJson() {
    return TupleExpressionSerializer.toMap(this);
  }
}

class ObjectExpression extends _ObjectExpression {
  ObjectExpression({this.keyValuePairs});

  @override
  final List<_KeyValuePair> keyValuePairs;

  ObjectExpression copyWith({List<_KeyValuePair> keyValuePairs}) {
    return new ObjectExpression(
        keyValuePairs: keyValuePairs ?? this.keyValuePairs);
  }

  Map<String, dynamic> toJson() {
    return ObjectExpressionSerializer.toMap(this);
  }
}

class KeyValuePair extends _KeyValuePair {
  KeyValuePair({this.key, this.value});

  @override
  final _Expression key;

  @override
  final _Expression value;

  KeyValuePair copyWith({_Expression key, _Expression value}) {
    return new KeyValuePair(key: key ?? this.key, value: value ?? this.value);
  }

  Map<String, dynamic> toJson() {
    return KeyValuePairSerializer.toMap(this);
  }
}

class Module extends _Module {
  Module({this.name, this.children, this.typedefs, this.functions});

  @override
  final String name;

  @override
  final List<_Module> children;

  @override
  final List<_Typedef> typedefs;

  @override
  final List<_FunctionIR> functions;

  Module copyWith(
      {String name,
      List<_Module> children,
      List<_Typedef> typedefs,
      List<_FunctionIR> functions}) {
    return new Module(
        name: name ?? this.name,
        children: children ?? this.children,
        typedefs: typedefs ?? this.typedefs,
        functions: functions ?? this.functions);
  }

  Map<String, dynamic> toJson() {
    return ModuleSerializer.toMap(this);
  }
}

class Typedef extends _Typedef {
  Typedef({this.span, this.name, this.type});

  @override
  final _Span span;

  @override
  final _Identifier name;

  @override
  final _Type type;

  Typedef copyWith({_Span span, _Identifier name, _Type type}) {
    return new Typedef(
        span: span ?? this.span,
        name: name ?? this.name,
        type: type ?? this.type);
  }

  Map<String, dynamic> toJson() {
    return TypedefSerializer.toMap(this);
  }
}

class FunctionIR extends _FunctionIR {
  FunctionIR(
      {this.span, this.name, this.parameters, this.returnType, this.body});

  @override
  final _Span span;

  @override
  final _Identifier name;

  @override
  final List<_Parameter> parameters;

  @override
  final _Type returnType;

  @override
  final List<_Statement> body;

  FunctionIR copyWith(
      {_Span span,
      _Identifier name,
      List<_Parameter> parameters,
      _Type returnType,
      List<_Statement> body}) {
    return new FunctionIR(
        span: span ?? this.span,
        name: name ?? this.name,
        parameters: parameters ?? this.parameters,
        returnType: returnType ?? this.returnType,
        body: body ?? this.body);
  }

  Map<String, dynamic> toJson() {
    return FunctionIRSerializer.toMap(this);
  }
}

class Parameter extends _Parameter {
  Parameter({this.span, this.name, this.type});

  @override
  final _Span span;

  @override
  final _Identifier name;

  @override
  final _Type type;

  Parameter copyWith({_Span span, _Identifier name, _Type type}) {
    return new Parameter(
        span: span ?? this.span,
        name: name ?? this.name,
        type: type ?? this.type);
  }

  Map<String, dynamic> toJson() {
    return ParameterSerializer.toMap(this);
  }
}

class Span extends _Span {
  Span({this.sourceUrl, this.start, this.end});

  @override
  final String sourceUrl;

  @override
  final _Location start;

  @override
  final _Location end;

  Span copyWith({String sourceUrl, _Location start, _Location end}) {
    return new Span(
        sourceUrl: sourceUrl ?? this.sourceUrl,
        start: start ?? this.start,
        end: end ?? this.end);
  }

  Map<String, dynamic> toJson() {
    return SpanSerializer.toMap(this);
  }
}

class Location extends _Location {
  Location({this.line, this.character});

  @override
  final int line;

  @override
  final int character;

  Location copyWith({int line, int character}) {
    return new Location(
        line: line ?? this.line, character: character ?? this.character);
  }

  Map<String, dynamic> toJson() {
    return LocationSerializer.toMap(this);
  }
}

class Statement extends _Statement {
  Statement({this.expression, this.variableDeclaration});

  @override
  final _ExpressionStatement expression;

  @override
  final _VariableDeclarationStatement variableDeclaration;

  Statement copyWith(
      {_ExpressionStatement expression,
      _VariableDeclarationStatement variableDeclaration}) {
    return new Statement(
        expression: expression ?? this.expression,
        variableDeclaration: variableDeclaration ?? this.variableDeclaration);
  }

  Map<String, dynamic> toJson() {
    return StatementSerializer.toMap(this);
  }
}

class ExpressionStatement extends _ExpressionStatement {
  ExpressionStatement({this.expression, this.isReturn});

  @override
  final _Expression expression;

  @override
  final bool isReturn;

  ExpressionStatement copyWith({_Expression expression, bool isReturn}) {
    return new ExpressionStatement(
        expression: expression ?? this.expression,
        isReturn: isReturn ?? this.isReturn);
  }

  Map<String, dynamic> toJson() {
    return ExpressionStatementSerializer.toMap(this);
  }
}

class VariableDeclarationStatement extends _VariableDeclarationStatement {
  VariableDeclarationStatement({this.variableDeclarations});

  @override
  final List<_VariableDeclaration> variableDeclarations;

  VariableDeclarationStatement copyWith(
      {List<_VariableDeclaration> variableDeclarations}) {
    return new VariableDeclarationStatement(
        variableDeclarations:
            variableDeclarations ?? this.variableDeclarations);
  }

  Map<String, dynamic> toJson() {
    return VariableDeclarationStatementSerializer.toMap(this);
  }
}

class VariableDeclaration extends _VariableDeclaration {
  VariableDeclaration({this.identifier, this.expression});

  @override
  final _Identifier identifier;

  @override
  final _Expression expression;

  VariableDeclaration copyWith(
      {_Identifier identifier, _Expression expression}) {
    return new VariableDeclaration(
        identifier: identifier ?? this.identifier,
        expression: expression ?? this.expression);
  }

  Map<String, dynamic> toJson() {
    return VariableDeclarationSerializer.toMap(this);
  }
}

class Type extends _Type {
  Type(
      {this.span,
      this.name,
      this.identifier,
      this.tuple,
      this.struct,
      this.function});

  @override
  final _Span span;

  @override
  final String name;

  @override
  final _IdentifierType identifier;

  @override
  final _TupleType tuple;

  @override
  final _StructType struct;

  @override
  final _FunctionType function;

  Type copyWith(
      {_Span span,
      String name,
      _IdentifierType identifier,
      _TupleType tuple,
      _StructType struct,
      _FunctionType function}) {
    return new Type(
        span: span ?? this.span,
        name: name ?? this.name,
        identifier: identifier ?? this.identifier,
        tuple: tuple ?? this.tuple,
        struct: struct ?? this.struct,
        function: function ?? this.function);
  }

  Map<String, dynamic> toJson() {
    return TypeSerializer.toMap(this);
  }
}

class IdentifierType extends _IdentifierType {
  IdentifierType({this.identifier});

  @override
  final _Identifier identifier;

  IdentifierType copyWith({_Identifier identifier}) {
    return new IdentifierType(identifier: identifier ?? this.identifier);
  }

  Map<String, dynamic> toJson() {
    return IdentifierTypeSerializer.toMap(this);
  }
}

class TupleType extends _TupleType {
  TupleType({this.items});

  @override
  final List<_Type> items;

  TupleType copyWith({List<_Type> items}) {
    return new TupleType(items: items ?? this.items);
  }

  Map<String, dynamic> toJson() {
    return TupleTypeSerializer.toMap(this);
  }
}

class StructType extends _StructType {
  StructType({this.fields});

  @override
  final Map<String, _Type> fields;

  StructType copyWith({Map<String, _Type> fields}) {
    return new StructType(fields: fields ?? this.fields);
  }

  Map<String, dynamic> toJson() {
    return StructTypeSerializer.toMap(this);
  }
}

class FunctionType extends _FunctionType {
  FunctionType({this.parameters, this.returnType});

  @override
  final List<_Type> parameters;

  @override
  final _Type returnType;

  FunctionType copyWith({List<_Type> parameters, _Type returnType}) {
    return new FunctionType(
        parameters: parameters ?? this.parameters,
        returnType: returnType ?? this.returnType);
  }

  Map<String, dynamic> toJson() {
    return FunctionTypeSerializer.toMap(this);
  }
}
