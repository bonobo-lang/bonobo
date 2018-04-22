# bonobo
[![build status](https://travis-ci.org/bonobo-lang/bonobo.svg?branch=master)](https://travis-ci.org/bonobo-lang/bonobo)

A strongly-typed, expressive language for safe systems programming.

[Language Specification](spec/README.md)

No semi colons.
No `null` (by default).
No B.S.

# Installation
This project is still in the early stages, so there is no easy method of distribution.
You will need to clone this repository, and then tell Dart's `pub` that you want the
`bonobo` executable in your global path:

```bash
git clone https://github.com/bonobo-lang/bonobo
pub global activate --source path bonobo/bonobo
```

If it is not already in your `PATH`, be sure to add the following, so that the `bonobo`
executable will be available in your terminal:

```bash
export PATH="~/.pub-cache/bin:$PATH"
```

# Usage
This project ships `bonobo`, a command-line executable that can be used to analyze or
compile Bonobo code.

## Print Module Information
This command reads the `*.bnb` files in the current directory, and computes a representation
of the environment as a *module* (see the [specification](spec/README.md#relation-to-modules)).

Run the following to dump module information:

```bash
bonobo info
```

## Language Server

Run:
`bonobo language_server`

* [x] Syntax checking
* [x] Static type checking
* [x] Type inference
* [x] Dead code detection
* [x] Autocompletion
* [x] Hover
* [x] Highlights
* [x] Symbol listing
* [x] Symbol reference/usage finding
