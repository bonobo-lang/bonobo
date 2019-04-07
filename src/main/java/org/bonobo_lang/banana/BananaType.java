package org.bonobo_lang.banana;

public abstract class BananaType {
    public abstract String getName();

    public abstract long computeSize(BananaSystem system);

    public <T> T accept(BananaTypeVisitor<T> visitor) {
        throw new UnsupportedOperationException();
    }
}
