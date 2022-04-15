module compiler.ir.ir_label;

import compiler.ir.ir_instruction;
import compiler.ir.ir_constant;
import compiler.config;

struct IR_Label
{
    IR_Instruction[] instructions;
    uint register_index;

    IR_Constant add_register()
    {
        return IR_Constant(register_index++);
    }

    void assign(IR_Constant a, IR_Constant b)
    {
        instructions ~= IR_Instruction([a, b], IR_InstructionKind.Assign);
    }

    void add(IR_Constant a, IR_Constant b, IR_Constant c)
    {
        instructions ~= IR_Instruction([a, b, c], IR_InstructionKind.Add);
    }

    void ret(IR_Constant a)
    {
        instructions ~= IR_Instruction([a], IR_InstructionKind.Return);
    }

    void cout(IR_Constant a)
    {
        instructions ~= IR_Instruction([a], IR_InstructionKind.ConsoleOutput);
    }
}