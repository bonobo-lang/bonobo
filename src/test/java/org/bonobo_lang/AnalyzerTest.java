package org.bonobo_lang;

import org.bonobo_lang.analysis.*;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class AnalyzerTest extends BonoboBaseTest {
    private BonoboFunction fnMain1() {
        return  (BonoboFunction) findSymbol("fn main => 1", "main").getValue();
    }

    @Test
    public void integersDefaultToInt64() {
        BonoboFunction main = fnMain1();
        BonoboBlockState state = main.getBody().getBody().get(0);
        BonoboReturnStatement retStmt = (BonoboReturnStatement) state.getStatement();
        BonoboValue retVal = retStmt.getReturnValue();
        BonoboIntegerType intType = (BonoboIntegerType) retVal.getType();
        assertEquals("i64", intType.getName());
    }

    @Test
    public void lambdaBlocksSetReturnValue() {
        BonoboFunction main = fnMain1();
        BonoboIntegerType intType = (BonoboIntegerType)main.getBody().getReturnType();
        assertEquals("i64", intType.getName());
    }

    @Test
    public void varDeclShouldInferType() {
        BonoboFunction main = (BonoboFunction) findSymbol("fn main { var x = 1 }", "main").getValue();

    }
}
