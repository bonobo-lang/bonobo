// GENERATED CODE - DO NOT MODIFY BY HAND

part of bonobo.ir;

// **************************************************************************
// Generator: SerializerGenerator
// **************************************************************************

abstract class IdentifierSerializer {
  static Identifier fromMap(Map map) {
    return new Identifier(namespaces: map['namespaces'], name: map['name']);
  }

  static Map<String, dynamic> toMap(Identifier model) {
    return {'namespaces': model.namespaces, 'name': model.name};
  }
}

abstract class IdentifierFields {
  static const String namespaces = 'namespaces';

  static const String name = 'name';
}

abstract class ExpressionSerializer {
  static Expression fromMap(Map map) {
    return new Expression(
        span: map['span'] != null ? SpanSerializer.fromMap(map['span']) : null,
        literal: map['literal'],
        identifier: map['identifier'] != null
            ? IdentifierSerializer.fromMap(map['identifier'])
            : null,
        binary: map['binary'] != null
            ? BinaryExpressionSerializer.fromMap(map['binary'])
            : null,
        object: map['object'] != null
            ? ObjectExpressionSerializer.fromMap(map['object'])
            : null,
        tuple: map['tuple'] != null
            ? TupleExpressionSerializer.fromMap(map['tuple'])
            : null);
  }

  static Map<String, dynamic> toMap(Expression model) {
    return {
      'span': SpanSerializer.toMap(model.span),
      'literal': model.literal,
      'identifier': IdentifierSerializer.toMap(model.identifier),
      'binary': BinaryExpressionSerializer.toMap(model.binary),
      'object': ObjectExpressionSerializer.toMap(model.object),
      'tuple': TupleExpressionSerializer.toMap(model.tuple)
    };
  }
}

abstract class ExpressionFields {
  static const String span = 'span';

  static const String literal = 'literal';

  static const String identifier = 'identifier';

  static const String binary = 'binary';

  static const String object = 'object';

  static const String tuple = 'tuple';
}

abstract class BinaryExpressionSerializer {
  static BinaryExpression fromMap(Map map) {
    return new BinaryExpression(
        left: map['left'] != null
            ? ExpressionSerializer.fromMap(map['left'])
            : null,
        right: map['right'] != null
            ? ExpressionSerializer.fromMap(map['right'])
            : null,
        op: map['op']);
  }

  static Map<String, dynamic> toMap(BinaryExpression model) {
    return {
      'left': ExpressionSerializer.toMap(model.left),
      'right': ExpressionSerializer.toMap(model.right),
      'op': model.op
    };
  }
}

abstract class BinaryExpressionFields {
  static const String left = 'left';

  static const String right = 'right';

  static const String op = 'op';
}

abstract class TupleExpressionSerializer {
  static TupleExpression fromMap(Map map) {
    return new TupleExpression(
        items: map['items'] is Iterable
            ? map['items'].map(ExpressionSerializer.fromMap).toList()
            : null);
  }

  static Map<String, dynamic> toMap(TupleExpression model) {
    return {'items': model.items?.map(ExpressionSerializer.toMap)?.toList()};
  }
}

abstract class TupleExpressionFields {
  static const String items = 'items';
}

abstract class ObjectExpressionSerializer {
  static ObjectExpression fromMap(Map map) {
    return new ObjectExpression(
        keyValuePairs: map['key_value_pairs'] is Iterable
            ? map['key_value_pairs']
                .map(KeyValuePairSerializer.fromMap)
                .toList()
            : null);
  }

  static Map<String, dynamic> toMap(ObjectExpression model) {
    return {
      'key_value_pairs':
          model.keyValuePairs?.map(KeyValuePairSerializer.toMap)?.toList()
    };
  }
}

abstract class ObjectExpressionFields {
  static const String keyValuePairs = 'key_value_pairs';
}

abstract class KeyValuePairSerializer {
  static KeyValuePair fromMap(Map map) {
    return new KeyValuePair(
        key: map['key'] != null
            ? ExpressionSerializer.fromMap(map['key'])
            : null,
        value: map['value'] != null
            ? ExpressionSerializer.fromMap(map['value'])
            : null);
  }

  static Map<String, dynamic> toMap(KeyValuePair model) {
    return {
      'key': ExpressionSerializer.toMap(model.key),
      'value': ExpressionSerializer.toMap(model.value)
    };
  }
}

abstract class KeyValuePairFields {
  static const String key = 'key';

  static const String value = 'value';
}

abstract class ModuleSerializer {
  static Module fromMap(Map map) {
    return new Module(
        name: map['name'],
        children: map['children'] is Iterable
            ? map['children'].map(ModuleSerializer.fromMap).toList()
            : null,
        typedefs: map['typedefs'] is Iterable
            ? map['typedefs'].map(TypedefSerializer.fromMap).toList()
            : null,
        functions: map['functions'] is Iterable
            ? map['functions'].map(FunctionIRSerializer.fromMap).toList()
            : null);
  }

  static Map<String, dynamic> toMap(Module model) {
    return {
      'name': model.name,
      'children': model.children?.map(ModuleSerializer.toMap)?.toList(),
      'typedefs': model.typedefs?.map(TypedefSerializer.toMap)?.toList(),
      'functions': model.functions?.map(FunctionIRSerializer.toMap)?.toList()
    };
  }
}

abstract class ModuleFields {
  static const String name = 'name';

  static const String children = 'children';

  static const String typedefs = 'typedefs';

  static const String functions = 'functions';
}

abstract class TypedefSerializer {
  static Typedef fromMap(Map map) {
    return new Typedef(
        span: map['span'] != null ? SpanSerializer.fromMap(map['span']) : null,
        name: map['name'] != null
            ? IdentifierSerializer.fromMap(map['name'])
            : null,
        type: map['type'] != null ? TypeSerializer.fromMap(map['type']) : null);
  }

  static Map<String, dynamic> toMap(Typedef model) {
    return {
      'span': SpanSerializer.toMap(model.span),
      'name': IdentifierSerializer.toMap(model.name),
      'type': TypeSerializer.toMap(model.type)
    };
  }
}

abstract class TypedefFields {
  static const String span = 'span';

  static const String name = 'name';

  static const String type = 'type';
}

abstract class FunctionIRSerializer {
  static FunctionIR fromMap(Map map) {
    return new FunctionIR(
        span: map['span'] != null ? SpanSerializer.fromMap(map['span']) : null,
        name: map['name'] != null
            ? IdentifierSerializer.fromMap(map['name'])
            : null,
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

  static Map<String, dynamic> toMap(FunctionIR model) {
    return {
      'span': SpanSerializer.toMap(model.span),
      'name': IdentifierSerializer.toMap(model.name),
      'parameters': model.parameters?.map(ParameterSerializer.toMap)?.toList(),
      'return_type': TypeSerializer.toMap(model.returnType),
      'body': model.body?.map(StatementSerializer.toMap)?.toList()
    };
  }
}

abstract class FunctionIRFields {
  static const String span = 'span';

  static const String name = 'name';

  static const String parameters = 'parameters';

  static const String returnType = 'return_type';

  static const String body = 'body';
}

abstract class ParameterSerializer {
  static Parameter fromMap(Map map) {
    return new Parameter(
        span: map['span'] != null ? SpanSerializer.fromMap(map['span']) : null,
        name: map['name'] != null
            ? IdentifierSerializer.fromMap(map['name'])
            : null,
        type: map['type'] != null ? TypeSerializer.fromMap(map['type']) : null);
  }

  static Map<String, dynamic> toMap(Parameter model) {
    return {
      'span': SpanSerializer.toMap(model.span),
      'name': IdentifierSerializer.toMap(model.name),
      'type': TypeSerializer.toMap(model.type)
    };
  }
}

abstract class ParameterFields {
  static const String span = 'span';

  static const String name = 'name';

  static const String type = 'type';
}

abstract class SpanSerializer {
  static Span fromMap(Map map) {
    return new Span(
        sourceUrl: map['source_url'],
        start: map['start'] != null
            ? LocationSerializer.fromMap(map['start'])
            : null,
        end:
            map['end'] != null ? LocationSerializer.fromMap(map['end']) : null);
  }

  static Map<String, dynamic> toMap(Span model) {
    return {
      'source_url': model.sourceUrl,
      'start': LocationSerializer.toMap(model.start),
      'end': LocationSerializer.toMap(model.end)
    };
  }
}

abstract class SpanFields {
  static const String sourceUrl = 'source_url';

  static const String start = 'start';

  static const String end = 'end';
}

abstract class LocationSerializer {
  static Location fromMap(Map map) {
    return new Location(line: map['line'], character: map['character']);
  }

  static Map<String, dynamic> toMap(Location model) {
    return {'line': model.line, 'character': model.character};
  }
}

abstract class LocationFields {
  static const String line = 'line';

  static const String character = 'character';
}

abstract class StatementSerializer {
  static Statement fromMap(Map map) {
    return new Statement(
        expression: map['expression'] != null
            ? ExpressionStatementSerializer.fromMap(map['expression'])
            : null,
        variableDeclaration: map['variable_declaration'] != null
            ? VariableDeclarationStatementSerializer
                .fromMap(map['variable_declaration'])
            : null);
  }

  static Map<String, dynamic> toMap(Statement model) {
    return {
      'expression': ExpressionStatementSerializer.toMap(model.expression),
      'variable_declaration': VariableDeclarationStatementSerializer
          .toMap(model.variableDeclaration)
    };
  }
}

abstract class StatementFields {
  static const String expression = 'expression';

  static const String variableDeclaration = 'variable_declaration';
}

abstract class ExpressionStatementSerializer {
  static ExpressionStatement fromMap(Map map) {
    return new ExpressionStatement(
        expression: map['expression'] != null
            ? ExpressionSerializer.fromMap(map['expression'])
            : null,
        isReturn: map['is_return']);
  }

  static Map<String, dynamic> toMap(ExpressionStatement model) {
    return {
      'expression': ExpressionSerializer.toMap(model.expression),
      'is_return': model.isReturn
    };
  }
}

abstract class ExpressionStatementFields {
  static const String expression = 'expression';

  static const String isReturn = 'is_return';
}

abstract class VariableDeclarationStatementSerializer {
  static VariableDeclarationStatement fromMap(Map map) {
    return new VariableDeclarationStatement(
        variableDeclarations: map['variable_declarations'] is Iterable
            ? map['variable_declarations']
                .map(VariableDeclarationSerializer.fromMap)
                .toList()
            : null);
  }

  static Map<String, dynamic> toMap(VariableDeclarationStatement model) {
    return {
      'variable_declarations': model.variableDeclarations
          ?.map(VariableDeclarationSerializer.toMap)
          ?.toList()
    };
  }
}

abstract class VariableDeclarationStatementFields {
  static const String variableDeclarations = 'variable_declarations';
}

abstract class VariableDeclarationSerializer {
  static VariableDeclaration fromMap(Map map) {
    return new VariableDeclaration(
        identifier: map['identifier'] != null
            ? IdentifierSerializer.fromMap(map['identifier'])
            : null,
        expression: map['expression'] != null
            ? ExpressionSerializer.fromMap(map['expression'])
            : null);
  }

  static Map<String, dynamic> toMap(VariableDeclaration model) {
    return {
      'identifier': IdentifierSerializer.toMap(model.identifier),
      'expression': ExpressionSerializer.toMap(model.expression)
    };
  }
}

abstract class VariableDeclarationFields {
  static const String identifier = 'identifier';

  static const String expression = 'expression';
}

abstract class TypeSerializer {
  static Type fromMap(Map map) {
    return new Type(
        span: map['span'] != null ? SpanSerializer.fromMap(map['span']) : null,
        name: map['name'],
        identifier: map['identifier'] != null
            ? IdentifierTypeSerializer.fromMap(map['identifier'])
            : null,
        tuple: map['tuple'] != null
            ? TupleTypeSerializer.fromMap(map['tuple'])
            : null,
        struct: map['struct'] != null
            ? StructTypeSerializer.fromMap(map['struct'])
            : null,
        function: map['function'] != null
            ? FunctionTypeSerializer.fromMap(map['function'])
            : null);
  }

  static Map<String, dynamic> toMap(Type model) {
    return {
      'span': SpanSerializer.toMap(model.span),
      'name': model.name,
      'identifier': IdentifierTypeSerializer.toMap(model.identifier),
      'tuple': TupleTypeSerializer.toMap(model.tuple),
      'struct': StructTypeSerializer.toMap(model.struct),
      'function': FunctionTypeSerializer.toMap(model.function)
    };
  }
}

abstract class TypeFields {
  static const String span = 'span';

  static const String name = 'name';

  static const String identifier = 'identifier';

  static const String tuple = 'tuple';

  static const String struct = 'struct';

  static const String function = 'function';
}

abstract class IdentifierTypeSerializer {
  static IdentifierType fromMap(Map map) {
    return new IdentifierType(
        identifier: map['identifier'] != null
            ? IdentifierSerializer.fromMap(map['identifier'])
            : null);
  }

  static Map<String, dynamic> toMap(IdentifierType model) {
    return {'identifier': IdentifierSerializer.toMap(model.identifier)};
  }
}

abstract class IdentifierTypeFields {
  static const String identifier = 'identifier';
}

abstract class TupleTypeSerializer {
  static TupleType fromMap(Map map) {
    return new TupleType(
        items: map['items'] is Iterable
            ? map['items'].map(TypeSerializer.fromMap).toList()
            : null);
  }

  static Map<String, dynamic> toMap(TupleType model) {
    return {'items': model.items?.map(TypeSerializer.toMap)?.toList()};
  }
}

abstract class TupleTypeFields {
  static const String items = 'items';
}

abstract class StructTypeSerializer {
  static StructType fromMap(Map map) {
    return new StructType(
        fields: map['fields'] is Map
            ? map['fields'].keys.fold({}, (out, key) {
                return out..[key] = TypeSerializer.fromMap(map['fields'][key]);
              })
            : null);
  }

  static Map<String, dynamic> toMap(StructType model) {
    return {
      'fields': model.fields.keys?.fold({}, (map, key) {
        return map..[key] = TypeSerializer.toMap(model.fields[key]);
      })
    };
  }
}

abstract class StructTypeFields {
  static const String fields = 'fields';
}

abstract class FunctionTypeSerializer {
  static FunctionType fromMap(Map map) {
    return new FunctionType(
        parameters: map['parameters'] is Iterable
            ? map['parameters'].map(TypeSerializer.fromMap).toList()
            : null,
        returnType: map['return_type'] != null
            ? TypeSerializer.fromMap(map['return_type'])
            : null);
  }

  static Map<String, dynamic> toMap(FunctionType model) {
    return {
      'parameters': model.parameters?.map(TypeSerializer.toMap)?.toList(),
      'return_type': TypeSerializer.toMap(model.returnType)
    };
  }
}

abstract class FunctionTypeFields {
  static const String parameters = 'parameters';

  static const String returnType = 'return_type';
}
