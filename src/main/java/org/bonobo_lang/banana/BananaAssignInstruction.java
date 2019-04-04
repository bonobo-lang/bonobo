package org.bonobo_lang.banana;

public class BananaAssignInstruction extends BananaInstruction {
    private final BananaVariable variable;
    private final BananaValue value;

    public BananaAssignInstruction(BananaVariable variable, BananaValue value) {
        this.variable = variable;
        this.value = value;
    }

    public BananaVariable getVariable() {
        return variable;
    }

    public BananaValue getValue() {
        return value;
    }

    @Override
    public <T> T accept(BananaInstructionVisitor<T> visitor) {
        return visitor.visitAssign(this);
    }
}
