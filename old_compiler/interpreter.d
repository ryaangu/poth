module compiler.interpreter;

import compiler.ir.ir_instruction;
import compiler.ir.ir_constant;
import compiler.ir.ir_label;

import std.stdio;

__gshared long[uint] registers;

void interpret(ref IR_Label label)
{
    writeln("-- INTERPRETED IR --");

    foreach (instruction; label.instructions)
    {
        switch (instruction.kind)
        {
            case IR_InstructionKind.Assign:
            {
                uint r = instruction.parameters[0].as_register;
                long v = instruction.parameters[1].as_integer;
                registers[r] = v;
                break;
            }

            case IR_InstructionKind.Add:
            {
                uint r = instruction.parameters[0].as_register;
                uint a = instruction.parameters[1].as_register;
                uint b = instruction.parameters[2].as_register;

                registers[r] = (registers[a] + registers[b]);
                break;
            }

            case IR_InstructionKind.ConsoleOutput:
            {
                uint r = instruction.parameters[0].as_register;
                writeln(registers[r]);
                break;
            }

            default:
                break;
        }
    }
}