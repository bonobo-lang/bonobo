# Get the actual dir
JAVA ?= java
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
# CLASSPATH := $(mkfile_dir)../../../target/classes:$(CLASSPATH)
BONOBO_JAR := $(mkfile_dir)../../../target/monkey_business-1.0-SNAPSHOT-jar-with-dependencies.jar
BONOBO = $(JAVA) -jar $(BONOBO_JAR)
exes = simplest simplest_variable

.PHONY: clean
all: $(exes)

llvm: simplest.ll simplest_variable.ll

simplest: simplest.o
	$(BONOBO) -o $@ $^

simplest_variable: simplest_variable.o
	$(BONOBO) -o $@ $^

clean:
	rm -f *.ll *.s *.o $(exes)

%.o: %.bnb
	$(BONOBO) -c -o $@ $<

%.ll: %.bnb
	$(BONOBO) -c -f llvm -o $@ $<
