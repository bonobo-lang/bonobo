// Generated from Bonobo.g4 by ANTLR 4.7.2

package org.bonobo_lang.frontend;

import org.antlr.v4.runtime.tree.ParseTreeVisitor;

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by {@link BonoboParser}.
 *
 * @param <T> The return type of the visit operation. Use {@link Void} for
 * operations with no return type.
 */
public interface BonoboVisitor<T> extends ParseTreeVisitor<T> {
	/**
	 * Visit a parse tree produced by {@link BonoboParser#prog}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitProg(BonoboParser.ProgContext ctx);
	/**
	 * Visit a parse tree produced by {@link BonoboParser#topLevel}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitTopLevel(BonoboParser.TopLevelContext ctx);
	/**
	 * Visit a parse tree produced by {@link BonoboParser#fnDecl}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitFnDecl(BonoboParser.FnDeclContext ctx);
	/**
	 * Visit a parse tree produced by the {@code BasicBlock}
	 * labeled alternative in {@link BonoboParser#block}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitBasicBlock(BonoboParser.BasicBlockContext ctx);
	/**
	 * Visit a parse tree produced by the {@code SingleStatementBlock}
	 * labeled alternative in {@link BonoboParser#block}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSingleStatementBlock(BonoboParser.SingleStatementBlockContext ctx);
	/**
	 * Visit a parse tree produced by the {@code LambdaBlock}
	 * labeled alternative in {@link BonoboParser#block}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitLambdaBlock(BonoboParser.LambdaBlockContext ctx);
	/**
	 * Visit a parse tree produced by the {@code NamedType}
	 * labeled alternative in {@link BonoboParser#type}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitNamedType(BonoboParser.NamedTypeContext ctx);
	/**
	 * Visit a parse tree produced by the {@code TupleType}
	 * labeled alternative in {@link BonoboParser#type}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitTupleType(BonoboParser.TupleTypeContext ctx);
	/**
	 * Visit a parse tree produced by the {@code ParenType}
	 * labeled alternative in {@link BonoboParser#type}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitParenType(BonoboParser.ParenTypeContext ctx);
	/**
	 * Visit a parse tree produced by the {@code CallStmt}
	 * labeled alternative in {@link BonoboParser#stmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitCallStmt(BonoboParser.CallStmtContext ctx);
	/**
	 * Visit a parse tree produced by the {@code VarDeclStmt}
	 * labeled alternative in {@link BonoboParser#stmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitVarDeclStmt(BonoboParser.VarDeclStmtContext ctx);
	/**
	 * Visit a parse tree produced by the {@code ReturnStmt}
	 * labeled alternative in {@link BonoboParser#stmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitReturnStmt(BonoboParser.ReturnStmtContext ctx);
	/**
	 * Visit a parse tree produced by the {@code IdExpr}
	 * labeled alternative in {@link BonoboParser#expr}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitIdExpr(BonoboParser.IdExprContext ctx);
	/**
	 * Visit a parse tree produced by the {@code HexExpr}
	 * labeled alternative in {@link BonoboParser#expr}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitHexExpr(BonoboParser.HexExprContext ctx);
	/**
	 * Visit a parse tree produced by the {@code CallExpr}
	 * labeled alternative in {@link BonoboParser#expr}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitCallExpr(BonoboParser.CallExprContext ctx);
	/**
	 * Visit a parse tree produced by the {@code IntExpr}
	 * labeled alternative in {@link BonoboParser#expr}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitIntExpr(BonoboParser.IntExprContext ctx);
	/**
	 * Visit a parse tree produced by the {@code ParenExpr}
	 * labeled alternative in {@link BonoboParser#expr}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitParenExpr(BonoboParser.ParenExprContext ctx);
}