//
// Created by Tobe on 4/26/18.
//

#include <cstring>
#include <fstream>
#include <iostream>
#include "bvm.h"

typedef struct
{
    const char *filename = nullptr;
    int argc;
    char **argv;
} Options;

class StandaloneChannel : public bvm::Channel
{
private:
    bvm::VM *vm;
public:
    StandaloneChannel();

    int exitCode = 0;

    bvm::VM *get_vm();

    void notifyMissingMethod(const char *str) override;

    void shutdown() override;

    void throwString(const char *str) override;

};

int runVM(Options &options);

void printHelp(std::ostream &stream) {
    stream << "usage: bvm [options] <filename>" << std::endl;
    stream << std::endl << "Options" << std::endl;
    stream << "--help, -h: Show this help information." << std::endl;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cerr << "fatal error: no input file" << std::endl;
        printHelp(std::cerr);
        return 1;
    }

    Options options;

    for (int i = 1; i < argc; i++) {
        auto *arg = argv[i];

        if (!strcmp(arg, "-h") || !strcmp(arg, "--help")) {
            printHelp(std::cout);
            return 0;
        } else {
            options.argc = argc - i;
            options.argv = argv + i;
            options.filename = arg;
            break;
        }
    }

    if (options.filename == nullptr) {
        std::cerr << "fatal error: no input file" << std::endl;
        printHelp(std::cerr);
        return 1;
    }

    return runVM(options);
}


int runVM(Options &options) {
    std::ifstream ifs(options.filename, std::ios::in | std::ios::binary);

    if (!ifs) {
        std::cerr << "fatal error: could not read file: \"" << options.filename << "\"" << std::endl;
        return 1;
    }

    ifs.ignore(std::numeric_limits<std::streamsize>::max());
    std::streamsize length = ifs.gcount();
    ifs.clear();
    ifs.seekg(0, std::ios_base::beg);

    // Minimum length of file should be:
    //
    // 0
    // + 3 ints (#header) = 12
    // + 1 long (# functions) = 8
    // = 20

    auto *errMalformed = "fatal error: invalid or malformed binary.";

    if (length < 20) {
        std::cerr << errMalformed << ". File is only " << length << " bytes in length." << std::endl;
        return 1;
    }

    auto data = new uint8_t[length];

    for (std::streamsize i = 0; i < length; i++)
        ifs >> data[i];

    ifs.close();

    // Verify magic
    auto magic = *((int32_t *) data);

    if (magic != 0xB090B0) {
        std::cerr << errMalformed << " First byte of file != 0xB090B0" << std::endl;
        return 1;
    }

    auto verifier = *((int32_t *) data + 4);
    auto hash = *((int32_t *) data + 8);

    // Verify that hash = (magic % verifier) >> 2
    int expectedHash = (magic % verifier) >> 2;

    if (hash != expectedHash) {
        std::cerr << errMalformed << " Malformed hash in header." << std::endl;
        return 1;
    }

    auto *channel = new StandaloneChannel;

    // Read functions.
    // A correctly-formed file has the # of functions as a long.
    auto nFunctions = *((uint64_t *) data + 12);
    const char *mainFunctionName = nullptr;
    std::streamsize idx = 0;

    for (uint64_t i = 0; i < nFunctions; i++) {
        // Each function starts with its full name.
        // Loop until we hit 0.
        std::streamsize j = idx;

        for (j; j < length; j++) {
            if (data[j] == 0)
                break;
        }

        if (j == idx || j == length) {
            // The name was never terminated.
            std::cerr << errMalformed << " Malformed function at index" << idx << "." << std::endl;
            return 1;
        }

        auto functionName = (char *) data + idx;

        if (idx == verifier - 1)
            mainFunctionName = functionName;

        // Next should be an unsigned long, which we will convert to intptr_t.
        auto len = *((long *) data + j + 1);
        auto *bytecode = (uint8_t *) len + 8;

        // Continue reading from after the bytecode.
        auto bytecodeEnd = ((long) bytecode) + len + 1;
        idx = (std::streamsize) bytecodeEnd;

        // Load the function.
        channel->get_vm()->loadFunction(functionName, len, bytecode);
    }

    if (mainFunctionName == nullptr) {
        std::cerr << "fatal error: module has no entry point" << std::endl;
        return 1;
    }

    // Invoke the main function.
    channel->get_vm()->execFunction((char *) mainFunctionName, options.argc, (void **) options.argv, true);

    // Delete the buffer;
    delete[] data;

    // Run the VM.
    channel->get_vm()->startLoop();
    return channel->exitCode;
}

StandaloneChannel::StandaloneChannel() {
    vm = new bvm::VM(this);
}

bvm::VM *StandaloneChannel::get_vm() {
    return vm;
}

void StandaloneChannel::notifyMissingMethod(const char *str) {
    std::cerr << "Unresolved function reference: " << std::endl;
    exitCode = 1;
    shutdown();
}

void StandaloneChannel::shutdown() {
    delete vm;
}

void StandaloneChannel::throwString(const char *str) {
    std::cerr << str << std::endl;
    exitCode = 1;
    shutdown();
}
