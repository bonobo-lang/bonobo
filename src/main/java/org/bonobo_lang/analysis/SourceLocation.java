package org.bonobo_lang.analysis;

import org.antlr.v4.runtime.ParserRuleContext;

public class SourceLocation {
    private long line;
    private long column;
    private String sourceUrl;

    public SourceLocation(String sourceUrl, long line, long column) {
        this.line = line;
        this.column = column;
        this.sourceUrl = sourceUrl;
    }

    public SourceLocation(String sourceUrl, ParserRuleContext ctx) {
        line = ctx.start.getLine();
        column = ctx.start.getCharPositionInLine() + 1;
        this.sourceUrl = sourceUrl;
    }

    public long getLine() {
        return line;
    }

    public long getColumn() {
        return column;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    @Override
    public String toString() {
        return String.format("%s:%d:%d", sourceUrl, line, column);
    }
}
