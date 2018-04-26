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
} Options;

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
    std::ifstream ifs(options.filename);

    if (!ifs) {
        std::cerr << "fatal error: could not read file: \"" << options.filename << "\"" << std::endl;
        return 1;
    }

    // TODO: Verify magic

    // TODO: Read functions

    // TODO: Run VM in custom channel

    return 0;
}


