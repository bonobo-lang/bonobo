package org.bonobo_lang.banana;

public abstract class BananaInstruction {
    public abstract <T> T accept(BananaInstructionVisitor<T> visitor);
}
