grammar Bonobo;

@header {
package org.bonobo_lang.frontend;
}

prog: topLevel*;
topLevel: fnDecl;
fnDecl: 'fn' ID (':' type)? block;
block:
    '{' stmt* '}' #BasicBlock
    | stmt #SingleStatementBlock
    | '=>' expr #LambdaBlock;
type:
    ID #NamedType
    | '(' (type ',')+ type ')' #TupleType
    | '(' type ')' #ParenType;
stmt:
    target=expr '(' ((args+=expr ',')* args+=expr)? ')' #CallStmt
    | 'var' ID (':' explicitType=type)? '=' expr #VarDeclStmt // TODO: Immutable variables
    | 'return'? expr #ReturnStmt;
expr:
    ID #IdExpr
    | HEX #HexExpr
    | INT #IntExpr
    | target=expr '(' ((args+=expr ',')* args+=expr)? ')' #CallExpr
    | '(' expr ')' #ParenExpr;

WS: [ \n\r\t]+ -> skip;
HEX: '0x' [A-Fa-f0-9]+;
INT: [0-9]+;
ID: [A-Za-z_] [A-Za-z0-9_]*;