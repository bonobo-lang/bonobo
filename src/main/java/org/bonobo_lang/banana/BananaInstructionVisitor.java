package org.bonobo_lang.banana;

public interface BananaInstructionVisitor<T> {
    T visitReturnConstant(BananaReturnConstantInstruction ctx);

    T visitAssign(BananaAssignInstruction ctx);
}

//public abstract class BananaInstructionVisitor<T> {
//    T visitReturnConstant(BananaReturnConstantInstruction ctx) {
//        throw new UnsupportedOperationException();
//    }
//
//    T visitAssign(BananaAssignInstruction ctx) {
//        throw new UnsupportedOperationException();
//    }
//}
