module compiler.ir.ir_builder;

import compiler.ir.ir_instruction;
import compiler.ir.ir_constant;
import compiler.ir.ir_label;
import compiler.ir.ir_type;

import std.stdio;

struct IR_Builder
{
    IR_Label[string] labels;

    IR_Label *add_label(string name)
    {
        labels[name] = IR_Label([], IR_Type(IR_TypeKind.Integer, 32), 0);
        return &(labels[name]);
    }

    void dump(ref IR_Type type)
    {
        final switch (type.kind)
        {
            case IR_TypeKind.Integer:
            {
                write("i", type.size);
                break;
            }
            
            case IR_TypeKind.Float:
            {
                write("f", type.size);
                break;
            }

            case IR_TypeKind.String:
            {
                write("i8[", type.size, "]");
                break;
            }
        }
    }

    void dump(ref IR_Constant constant)
    {
        final switch (constant.kind)
        {
            case IR_ConstantKind.Integer:
            {
                write(constant.as_integer);
                break;
            }

            case IR_ConstantKind.Float:
            {
                write(constant.as_float);
                break;
            }

            case IR_ConstantKind.String:
            {
                write("\"", constant.as_string, "\"");
                break;
            }

            case IR_ConstantKind.Register:
            {
                write("$", constant.as_register);
                break;
            }
        }
    }

    void dump(ref IR_Instruction instruction)
    {
        final switch (instruction.kind)
        {
            case IR_InstructionKind.Assign:
            {
                dump(instruction.parameters[0]);
                write(": ");
                dump(instruction.parameters[1].type);
                write(" = ");
                dump(instruction.parameters[1]);
                writeln(";");
                break;
            }

            case IR_InstructionKind.Add:
            {
                dump(instruction.parameters[0]);
                write(" = ");
                dump(instruction.parameters[1]);
                write(" + ");
                dump(instruction.parameters[2]);
                writeln(";");
                break;
            }

            case IR_InstructionKind.Return:
            {
                write("return ");
                dump(instruction.parameters[0]);
                writeln(";");
                break;
            }

            case IR_InstructionKind.ConsoleOutput:
            {
                write("console.output(");
                dump(instruction.parameters[0]);
                writeln(");");
                break;
            }
        }
    }

    void dump()
    {
        writeln("-- IR DUMP --\n");
        
        foreach (key, value; labels)
        {
            write("void ", key, "()\n");
            write("{\n");

            foreach (instruction; value.instructions)
            {
                write("    ");
                dump(instruction);
            }

            write("}\n\n");
        }

        writeln();
    }
}