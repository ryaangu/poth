module compiler.frontend.node;

import compiler.input;

import compiler.ir.ir_constant;

import std.stdio;

class Node
{
    void emit(ref Input input)
    {

    }
}

class NodeFunction : Node
{
    string name;
    Node[] in_effects;
    Node[] out_effects;
    Node[] statements;

    override void emit(ref Input input)
    {
        input.label = input.ir.add_label(name);

        foreach (node; statements)
            node.emit(input);
    }
}

class NodeInteger : Node
{
    long value;

    this(long _value)
    {
        value = _value;
    }

    override void emit(ref Input input)
    {
        input.push(IR_Constant(value));
    }
}

class NodeFloat : Node
{
    double value;

    this(double _value)
    {
        value = _value;
    }

    override void emit(ref Input input)
    {
        input.push(IR_Constant(value));
    }
}

class NodeString : Node
{
    string value;

    this(string _value)
    {
        value = _value;
    }

    override void emit(ref Input input)
    {
        input.push(IR_Constant(value));
    }
}

class NodeConsoleOutput : Node 
{
    override void emit(ref Input input)
    {
        input.label.cout(input.pop());
    }
}

class NodeAdd : Node
{
    override void emit(ref Input input)
    {
        IR_Constant a = input.pop();
        IR_Constant b = input.pop();

        IR_Constant register = input.label.add_register();
        input.stack ~= register.as_register;
        input.label.add(register, a, b);
    }
}

class NodeIdentifier : Node
{
    string name;

    this(string _name)
    {
        name = _name;
    }

    override void emit(ref Input input)
    {
        
    }
}