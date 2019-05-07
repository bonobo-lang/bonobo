package org.bonobo_lang.banana;

public class BananaStaticReturnInstruction extends BananaInstruction {
    private final BananaVariable variable;

    public BananaStaticReturnInstruction(BananaVariable variable) {
        this.variable = variable;
    }

    public BananaVariable getVariable() {
        return variable;
    }

    @Override
    public <T> T accept(BananaInstructionVisitor<T> visitor) {
        return visitor.visitStaticReturn(this);
    }
}
