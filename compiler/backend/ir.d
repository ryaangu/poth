module compiler.backend.ir;

import std.stdio;

struct IRLabel
{
    IRInstruction[] instructions;
    IRConstant[] variables;

    IRConstant variable()
    {
        variables ~= IRConstant();
        return IRConstant(cast(int)variables.length - 1);
    }

    void set(IRConstant a, IRConstant b)
    {
        writeln("$", a.as_variable, " = ", b.as_float);
        instructions ~= IRInstruction(IRInstructionKind.Set, [a, b]);
    }

    void add(IRConstant a, IRConstant b, IRConstant c)
    {
        writeln("$", a.as_variable, " = $", c.as_variable, " + $", b.as_variable);
        instructions ~= IRInstruction(IRInstructionKind.Add, [a, b]);
    }

    void ret(IRConstant a)
    {
        writeln("ret $", a.as_variable);
        instructions ~= IRInstruction(IRInstructionKind.Ret, [a]);
    }

    void cout(IRConstant a)
    {
        writeln("console.output($", a.as_variable, ')');
        instructions ~= IRInstruction(IRInstructionKind.COut, [a]);
    } 
}

enum IRInstructionKind
{
    Set,
    Add,
    Ret,
    COut,
}

struct IRInstruction
{
    IRInstructionKind kind;
    IRConstant[] parameters;
    IRConstant destination;
}

enum IRConstantKind
{
    Float,
    Variable,
}

struct IRConstant
{
    union
    {
        double as_float;
        int as_variable;
    }

    IRConstantKind kind;

    this(double value)
    {
        as_float = value;
        kind = IRConstantKind.Float;
    }

    this(int value)
    {
        as_variable = value;
        kind = IRConstantKind.Variable;
    }
}