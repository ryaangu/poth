module compiler.ir.ir_instruction;

import compiler.ir.ir_constant;

enum IR_InstructionKind
{
    Assign,

    Add,

    Return,

    ConsoleOutput,
}

struct IR_Instruction
{
    IR_Constant[] parameters;
    IR_InstructionKind kind;
}