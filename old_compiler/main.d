module compiler.main;

import std.stdio;
import std.file;

import compiler.frontend.parser;
import compiler.frontend.node;

import compiler.config;
import compiler.input;

void main()
{
    g_inputs ~= Input("tests/test.pth", readText("tests/test.pth") ~ "\0");

    Parser p;
    p.start();

    foreach (node; g_inputs[0].nodes)
        node.emit(g_inputs[0]);

    g_inputs[0].ir.dump();
}