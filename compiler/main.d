module compiler.main;

import std.stdio;

import compiler.backend.emitter;
import compiler.interpreter;

import compiler.ir.ir_constant;
import compiler.ir.ir_builder;
import compiler.ir.ir_label;

void main()
{
    Emitter gen;
    gen.start();

    gen.builder.dump();
    interpret(*gen.current_label);
}