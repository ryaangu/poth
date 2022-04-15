module compiler.main;

import std.stdio;
import compiler.backend.gen;

void main()
{
    Generator gen;
    gen.start();
}