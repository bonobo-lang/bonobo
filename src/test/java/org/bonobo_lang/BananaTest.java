package org.bonobo_lang;

import org.bonobo_lang.banana.BananaFunction;
import org.bonobo_lang.banana.BananaModule;
import org.junit.Assert;
import org.junit.Test;

public class BananaTest extends BonoboBaseTest {
    private BananaModule fnMain1() {
        return compileToBanana("fn main => 1");
    }

    @Test
    public void shouldGenerateConstantIntReturn() {
        BananaModule module = fnMain1();
        BananaFunction main = module.getFunctions().get(0);
        Assert.assertEquals("main", main.getName());
        Assert.assertEquals(main.getReturnType().getName(), "i64");
    }
}
