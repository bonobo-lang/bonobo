package org.bonobo_lang.banana;

public class BananaVoidType extends BananaType {
    @Override
    public String getName() {
        return "void";
    }

    @Override
    public long computeSize(BananaSystem system) {
        return 0;
    }

    @Override
    public <T> T accept(BananaTypeVisitor<T> visitor) {
        return visitor.visitVoidType(this);
    }
}
