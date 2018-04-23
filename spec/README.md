 # The Bonobo Programming Language Specification
 *This document is not yet final. Expect continuous changes.*

* [About](#about)
    * [Syntax Specification](#syntax-specification)
* [Compilation Unit](#compilation-unit)
    * [Relation to Modules](#relation-to-modules)
* [Top Level Declaration](#top-level-declaration)
    * [Import Declaration](#import-declaration)
    * [Function Declaration](#function-declaration)
        * [Function Signature](#function-signature)
        * [Function Body](#function-body)
            * [Expression Function Body](#expression-function-body)
            * [Block Function Body](#block-function-body)
                * [Block](#block)
    * [Typedef Declaration](#typedef-declaration)
    * [Sugared Enumeration Type Declaration](#sugared-enumeration-type-declaration)
* [Type](#type)
    * [Named Type](#named-type)
    * [Enumeration Type](#enumeration-type)
    * [Tuple Type](#tuple-type)
    * [Struct Type](#struct-type)
    * [Array Type](#named-type)
    * [Parameterized Type](#parameterized-type)

 ## About
This document defines the *syntax* of Bonobo, a strongly-typed
language intended for safe systems development.

Bonobo aims for consistent syntax and rigid type-checking,
while also supporting a system of composable types that
can grow to describe any type of data.

### Syntax Specification
The syntax used in this document to describe the language
is a variant of EBNF. Productions may offer alternatives, separated by `|`. Options suffixed with `*` may appear zero or
more times, while those suffixed with `+` may appear one or
more times. Units within productions are not separated by commas,
for brevity's sake.

Example:

```ebnf
MyProduction: "Foo" | Bar+ | Baz*
```

# Compilation Unit
Bonobo is a language expressed in *compilation units*. A
compilation unit, simply put, is a file containing Bonobo code.
A compilation unit may contain an infinite number of
[top-level declarations](#top-level-declaration).

```ebnf
CompilationUnit: TopLevelDeclaration*;
```

## Relation to Modules
An individual compilation unit is part of a *module*, which is a
structed collection of all the top-level declarations defined in all the
files in a given directory with the extension `.bnb`, after static analysis.
These modules are a cumulative representation of code written by a user,
and are the intermediate representation of code fed to Bonobo's compilation
backend(s).

# Top Level Declaration
A *top-level declaration* is a mechanism for declaring symbols within a Bonobo
[module](#relation-to-modules).

```ebnf
TopLevelDeclaration:
    ImportDeclaration
    | FunctionDeclaration
    | TypedefDeclaration
    | SugaredEnumTypeDeclaration;
```

## Import Declaration

## Function Declaration
Many languages allow *functions* as mechanisms to store units of
reusable code. Bonobo is no different; in fact, functions are
supported both as top-level declarations and as
[expressions](#expression).

```ebnf
FunctionDeclaration: "fn" SimpleIdentifier FunctionSignature? FunctionBody;
```

### Function Signature
A *function signature* formally specifies the names and types
of parameters a function expects, as well as defining a return
type.

A function signature is only necessary if the given function
takes parameters, or wants to explicitly specify a return type.

```ebnf
FunctionSignature: ParameterList? Type?;
```

### Function Body
The reusable sequence of code contained in a function is called
its *body*.

```ebnf
FunctionBody: ExpressionFunctionBody | BlockFunctionBody;
```

#### Expression Function Body
This type of function body exists as a shorthand syntax for
functions that immediately return a value. Internally, this
is expanded into a [block function body](#block-function-body).

```ebnf
ExpressionFunctionBody: "=>" Expression;
```

#### Block Function Body
This is the most common type of function body. It defines a series
of zero or more [statements](#statement) to be executed
sequentially at runtime.

```ebnf
BlockFunctionBody: Block;
```

##### Block
This is the formal definition of a *block*, a group of
zero or more statements that represents a series of actions.

```ebnf
Block: "{" Statement* "}";
```

## Typedef Declaration
In Bonobo, all data can be classified into *types*.
Some types are complex or composite, and explicitly typing
them every time would be cumbersome. *Typedefs* are
special declarations that can be used to assign an alias
to an anonymous, or otherwise verbose, type.

```ebnf
TypedefDeclaration: "type" SimpleIdentifier "="? Type;
```

## Sugared Enumeration Type Declaration
Bonobo also supports a shorthand syntax for declaring enumeration types
types. While I personally don't think it's very necessary, it's
clear that people coming from languages like C or C++ might find
[the original syntax](#enumeration-type) verbose.

```ebnf
SugaredEnumTypeDeclaration: "enum" SimpleIdentifier "{" ( (EnumValue ",")* EnumValue )? "}";
```

# Type
Bonobo supports a rich type system, in the hopes that allowing great expressiveness
will give the language room to grow autonomously, along with its community.

```ebnf
Type:
    NamedType
    | EnumType
    | TupleType
    | StructType
    | ArrayType
    | ParameterizedType
    | "(" Type ")";
```

## Named Type
A *named type* in itself is not a type, but a reference to another type,
either one defined in the standard library, or one defined in a [typedef](#typedef-declaration).

```ebnf
NamedType: Identifier;
```

## Enumeration Type
An *enumeration type* (*enum type* for short) is a type that contains a defined
set of possible values, known both to the user and to the compiler.


```ebnf
EnumType: "enum" SimpleIdentifier "{" ( (EnumValue ",")* EnumValue )? "}";
```

### Enum Value
An *enumeration value* has an associated integer value. This can be inferred from
its index within the containing enumeration, or manually specified.

```ebnf
EnumValue: SimpleIdentifier ("=" NumberLiteral)?;
```

## Tuple Type
A *tuple type* is a composite type consisting of two or more types.
Any expression of this tuple type must contain an equal number of members,
with types in the exact order as defined in the tuple literal.

For example, take the tuple type `Int, String`. The [tuple expression](#tuple-expression)
 `2, "two"` would be a valid expression, but `"two", 2` would not.

```ebnf
TupleType: "(" ( (Type ",")* Type )? ")";
```

## Struct Type

## Array Type

## Parameterized Type