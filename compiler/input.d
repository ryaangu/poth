module compiler.input;

import compiler.frontend.scanner;
import compiler.frontend.node;

import compiler.symbol;

import compiler.ir.ir_builder;
import compiler.ir.ir_label;
import compiler.ir.ir_constant;

import std.stdio;

struct Input
{
    string path;
    string source;
    Scanner scanner;
    Node[] nodes;
    Symbol[string] symbols;
    IR_Builder ir;
    IR_Label *label;
    uint[] stack;

    this(string _path, string _source)
    {
        path = _path;
        source = _source;
        scanner = Scanner(source);
    }

    void push(IR_Constant constant)
    {
        IR_Constant register = label.add_register();
        label.assign(register, constant);
        stack ~= register.as_register;
    }

    IR_Constant pop()
    {
        if (stack.length == 0)
            writeln("tried to pop nothing.");

        uint register = stack[$ - 1];
        --stack.length;

        return IR_Constant(register);
    }
}