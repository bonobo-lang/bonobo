package org.bonobo_lang.analysis;

public class BonoboError {
    public enum Severity {
        error, warning, info
    }

    private Severity severity;
    private SourceLocation location;
    private String message;

    public BonoboError(Severity severity, SourceLocation location, String message) {
        this.severity = severity;
        this.location = location;
        this.message = message;
    }

    public Severity getSeverity() {
        return severity;
    }

    public SourceLocation getLocation() {
        return location;
    }

    public String getMessage() {
        return message;
    }
}
