// GENERATED CODE - DO NOT MODIFY BY HAND

part of bonobo.compiler.ll;

// **************************************************************************
// Generator: SerializerGenerator
// **************************************************************************

abstract class CompilationUnitSerializer {
  static CompilationUnit fromMap(Map map) {
    return new CompilationUnit(
        typedefs: map['typedefs'] is Iterable
            ? map['typedefs'].map(TypedefSerializer.fromMap).toList()
            : null,
        enums: map['enums'] is Iterable
            ? map['enums'].map(EnumSerializer.fromMap).toList()
            : null,
        functions: map['functions'] is Iterable
            ? map['functions'].map(FunctionLLSerializer.fromMap).toList()
            : null);
  }

  static Map<String, dynamic> toMap(CompilationUnit model) {
    return {
      'typedefs': model.typedefs?.map(TypedefSerializer.toMap)?.toList(),
      'enums': model.enums?.map(EnumSerializer.toMap)?.toList(),
      'functions': model.functions?.map(FunctionLLSerializer.toMap)?.toList()
    };
  }
}

abstract class CompilationUnitFields {
  static const String typedefs = 'typedefs';

  static const String enums = 'enums';

  static const String functions = 'functions';
}

abstract class TypedefSerializer {
  static Typedef fromMap(Map map) {
    return new Typedef(
        name: map['name'],
        type: map['type'] != null ? TypeSerializer.fromMap(map['type']) : null);
  }

  static Map<String, dynamic> toMap(Typedef model) {
    return {'name': model.name, 'type': TypeSerializer.toMap(model.type)};
  }
}

abstract class TypedefFields {
  static const String name = 'name';

  static const String type = 'type';
}

abstract class EnumSerializer {
  static Enum fromMap(Map map) {
    return new Enum(name: map['name'], values: map['values']);
  }

  static Map<String, dynamic> toMap(Enum model) {
    return {'name': model.name, 'values': model.values};
  }
}

abstract class EnumFields {
  static const String name = 'name';

  static const String values = 'values';
}

abstract class FunctionLLSerializer {
  static FunctionLL fromMap(Map map) {
    return new FunctionLL(
        name: map['name'],
        parameters: map['parameters'] is Iterable
            ? map['parameters'].map(ParameterSerializer.fromMap).toList()
            : null,
        returnType: map['return_type'] != null
            ? TypeSerializer.fromMap(map['return_type'])
            : null,
        body: map['body'] is Iterable
            ? map['body'].map(StatementSerializer.fromMap).toList()
            : null);
  }

  static Map<String, dynamic> toMap(FunctionLL model) {
    return {
      'name': model.name,
      'parameters': model.parameters?.map(ParameterSerializer.toMap)?.toList(),
      'return_type': TypeSerializer.toMap(model.returnType),
      'body': model.body?.map(StatementSerializer.toMap)?.toList()
    };
  }
}

abstract class FunctionLLFields {
  static const String name = 'name';

  static const String parameters = 'parameters';

  static const String returnType = 'return_type';

  static const String body = 'body';
}

abstract class ParameterSerializer {
  static Parameter fromMap(Map map) {
    return new Parameter(
        name: map['name'],
        type: map['type'] != null ? TypeSerializer.fromMap(map['type']) : null);
  }

  static Map<String, dynamic> toMap(Parameter model) {
    return {'name': model.name, 'type': TypeSerializer.toMap(model.type)};
  }
}

abstract class ParameterFields {
  static const String name = 'name';

  static const String type = 'type';
}

abstract class StatementSerializer {
  static Statement fromMap(Map map) {
    return new Statement(
        expression: map['expression'] != null
            ? ExpressionStatementSerializer.fromMap(map['expression'])
            : null);
  }

  static Map<String, dynamic> toMap(Statement model) {
    return {
      'expression': ExpressionStatementSerializer.toMap(model.expression)
    };
  }
}

abstract class StatementFields {
  static const String expression = 'expression';
}

abstract class ExpressionStatementSerializer {
  static ExpressionStatement fromMap(Map map) {
    return new ExpressionStatement(isReturn: map['is_return']);
  }

  static Map<String, dynamic> toMap(ExpressionStatement model) {
    return {'is_return': model.isReturn};
  }
}

abstract class ExpressionStatementFields {
  static const String isReturn = 'is_return';
}

abstract class StructSerializer {
  static Struct fromMap(Map map) {
    return new Struct(
        name: map['name'],
        fields: map['fields'] is Iterable
            ? map['fields'].map(FieldSerializer.fromMap).toList()
            : null);
  }

  static Map<String, dynamic> toMap(Struct model) {
    return {
      'name': model.name,
      'fields': model.fields?.map(FieldSerializer.toMap)?.toList()
    };
  }
}

abstract class StructFields {
  static const String name = 'name';

  static const String fields = 'fields';
}

abstract class FieldSerializer {
  static Field fromMap(Map map) {
    return new Field(
        name: map['name'],
        type: map['type'] != null ? TypeSerializer.fromMap(map['type']) : null);
  }

  static Map<String, dynamic> toMap(Field model) {
    return {'name': model.name, 'type': TypeSerializer.toMap(model.type)};
  }
}

abstract class FieldFields {
  static const String name = 'name';

  static const String type = 'type';
}

abstract class TypeSerializer {
  static Type fromMap(Map map) {
    return new Type(
        name: map['name'],
        pointer: map['pointer'] != null
            ? PointerTypeSerializer.fromMap(map['pointer'])
            : null,
        array: map['array'] != null
            ? ArrayTypeSerializer.fromMap(map['array'])
            : null);
  }

  static Map<String, dynamic> toMap(Type model) {
    return {
      'name': model.name,
      'pointer': PointerTypeSerializer.toMap(model.pointer),
      'array': ArrayTypeSerializer.toMap(model.array)
    };
  }
}

abstract class TypeFields {
  static const String name = 'name';

  static const String pointer = 'pointer';

  static const String array = 'array';
}

abstract class PointerTypeSerializer {
  static PointerType fromMap(Map map) {
    return new PointerType(
        inner:
            map['inner'] != null ? TypeSerializer.fromMap(map['inner']) : null);
  }

  static Map<String, dynamic> toMap(PointerType model) {
    return {'inner': TypeSerializer.toMap(model.inner)};
  }
}

abstract class PointerTypeFields {
  static const String inner = 'inner';
}

abstract class ArrayTypeSerializer {
  static ArrayType fromMap(Map map) {
    return new ArrayType(
        inner:
            map['inner'] != null ? TypeSerializer.fromMap(map['inner']) : null,
        size: map['size']);
  }

  static Map<String, dynamic> toMap(ArrayType model) {
    return {'inner': TypeSerializer.toMap(model.inner), 'size': model.size};
  }
}

abstract class ArrayTypeFields {
  static const String inner = 'inner';

  static const String size = 'size';
}
