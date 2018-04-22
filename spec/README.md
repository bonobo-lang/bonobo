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
    | TypedefDeclaration;
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
