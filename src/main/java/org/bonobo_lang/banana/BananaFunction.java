package org.bonobo_lang.banana;

import java.util.ArrayList;
import java.util.List;

public class BananaFunction {
    private final List<BananaBlock> blocks = new ArrayList<>();
    private final String name;
    private final BananaType type;
    private final BananaBlock entryBlock;

    public BananaFunction(String name, BananaType type) {
        this.name = name;
        this.type = type;
        entryBlock = new BananaBlock("entry");
        blocks.add(entryBlock);
    }

    public List<BananaBlock> getBlocks() {
        return blocks;
    }

    public String getName() {
        return name;
    }

    public BananaBlock getEntryBlock() {
        return entryBlock;
    }

    public BananaType getType() {
        return type;
    }
}