package org.bonobo_lang.banana;

import java.util.ArrayList;
import java.util.List;

public class BananaBlock {
    private final List<BananaInstruction> instructions = new ArrayList<>();
    private final String name;

    public BananaBlock(String name) {
        this.name = name;
    }

    public List<BananaInstruction> getInstructions() {
        return instructions;
    }

    public String getName() {
        return name;
    }
}
