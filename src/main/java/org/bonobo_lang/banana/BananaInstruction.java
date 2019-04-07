package org.bonobo_lang.banana;

public abstract class BananaInstruction {
    public <T> T accept(BananaInstructionVisitor<T> visitor) {
        throw new UnsupportedOperationException();
    }
}
