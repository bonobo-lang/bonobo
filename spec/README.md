 # The Bonobo Programming Language Specification
 *This document is not yet final. Expect continuous changes.*

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
more times.

Example:

```ebnf
MyProduction: "Foo" | Bar+ | Baz*
```

## Contents
* [Compilation Unit](#compilation-unit)
    * [Relation to Modules](#relation-to-modules)

# Compilation Unit
Bonobo is a language expressed in *compilation units*. A
compilation unit, simply put, is a file containing Bonobo code.
A compilation unit may contain an infinite number of top-level declarations.

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