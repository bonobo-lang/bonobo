package org.bonobo_lang.analysis;

public class SourceLocation {
    private long line;
    private long column;

    public SourceLocation(long line, long column) {
        this.line = line;
        this.column = column;
    }

    public long getLine() {
        return line;
    }

    public long getColumn() {
        return column;
    }
}
