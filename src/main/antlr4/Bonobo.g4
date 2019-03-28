grammar Bonobo;

@header {
package org.bonobo_lang;
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
    | 'return'? expr #ReturnStmt;
expr:
    ID #IdExpr
    | target=expr '(' ((args+=expr ',')* args+=expr)? ')' #CallExpr
    | '(' expr ')' #ParenExpr;

WS: [ \n\r\t]+ -> skip;
ID: [A-Za-z_] [A-Za-z0-9_]*;