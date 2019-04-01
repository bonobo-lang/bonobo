package org.bonobo_lang.analysis;

public class BonoboCoreModule extends BonoboModule {
    private final BonoboIntegerType int8Type = new BonoboIntegerType("i8", 1, false);
    private final BonoboIntegerType int16Type = new BonoboIntegerType("i16", 2, false);
    private final BonoboIntegerType int32Type = new BonoboIntegerType("i32", 4, false);
    private final BonoboIntegerType int64Type = new BonoboIntegerType("i64", 8, false);
    private final BonoboIntegerType uint8Type = new BonoboIntegerType("u8", 1, true);
    private final BonoboIntegerType uint16Type = new BonoboIntegerType("u16", 2, true);
    private final BonoboIntegerType uint32Type = new BonoboIntegerType("u32", 4, true);
    private final BonoboIntegerType uint64Type = new BonoboIntegerType("u64", 8, true);

    public BonoboCoreModule(BonoboScope scope) {
        super(scope, "bonobo");
    }

    public BonoboIntegerType getInt8Type() {
        return int8Type;
    }

    public BonoboIntegerType getInt16Type() {
        return int16Type;
    }

    public BonoboIntegerType getInt32Type() {
        return int32Type;
    }

    public BonoboIntegerType getInt64Type() {
        return int64Type;
    }

    public BonoboIntegerType getUint8Type() {
        return uint8Type;
    }

    public BonoboIntegerType getUint16Type() {
        return uint16Type;
    }

    public BonoboIntegerType getUint32Type() {
        return uint32Type;
    }

    public BonoboIntegerType getUint64Type() {
        return uint64Type;
    }
}
