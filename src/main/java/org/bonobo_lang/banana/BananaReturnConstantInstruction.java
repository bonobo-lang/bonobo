package org.bonobo_lang.banana;

import org.bonobo_lang.analysis.BonoboConstant;

public class BananaReturnConstantInstruction extends BananaInstruction {
    private final BonoboConstant value;

    public BananaReturnConstantInstruction(BonoboConstant value) {
        this.value = value;
    }

    public BonoboConstant getValue() {
        return value;
    }
}
