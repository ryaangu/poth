module compiler.common.ir.definition;

import compiler.common.ir.basic_block;
import compiler.common.ir.constant;
import compiler.common.ir.instruction;
import compiler.common.ir.register;
import compiler.common.ir.type;

import std.stdio;

/// A structure that represents a definition (a function).
struct Definition 
{
    /// The name of the definition.
    string name;

    /// The type of the definition.
    Type type;

    /// The amount of parameters of the definition.
    uint paratemerCount;

    /// All the basic blocks inside this definition.
    BasicBlock[] basicBlocks;

    /// The registers in this definition.
    Register[] registers;

    /// The values of the registers in this definition.
    Constant[] values;

    /// The current basic block we are in.
    BasicBlock *basicBlock;

    /** 
        Adds basic block to definition.

        Returns:
            The basic block that was added.
    */
    BasicBlock *addBasicBlock()
    {
        basicBlocks ~= BasicBlock(cast(uint)basicBlocks.length - 1);
        basicBlock   = &(basicBlocks[$ - 1]);
        return basicBlock;
    }

    /** 
        Adds register to definition.

        Returns:
            The register that was added.
    */
    Register *addRegister(Type type)
    {
        registers ~= Register(cast(int)registers.length - 1, type);
        return &(registers[$ - 1]);
    }

    /**
        Adds instruction to current basic block.

        Params:
            instruction = The instruction to be added.
    */
    void addInstruction(Instruction instruction)
    {
        // Check for assignment instruction.
        if (instruction.kind == InstructionKind.Assign)
        {
            // Get register index
            uint registerIndex = instruction.parameters[0].asRegister.index;

            // Increase values array if needed
            if (values.length < (registerIndex + 1))
                values.length += (registerIndex + 1);

            // Set register value
            values[registerIndex] = instruction.parameters[1];
        }

        basicBlock.instructions ~= instruction;
    }

    /** 
        Dumps constant to console.

        Params:
            constant = The constant to be dumped.
    */
    void dump(ref Constant constant)
    {
        // Check for constant kind.
        final switch (constant.kind)
        {
            // Integer
            case ConstantKind.Integer:
            {
                write(constant.asInteger);
                break;
            }

            // Float
            case ConstantKind.Float:
            {
                write(constant.asFloat);
                break;
            }

            // String
            case ConstantKind.String:
            {
                write('"', constant.asString, '"');
                break;
            }

            // Register
            case ConstantKind.Register:
            {
                dump(constant.asRegister);
                break;
            }
        }
    }

    /** 
        Dumps register to console.

        Params:
            register = The register to be dumped.
    */
    void dump(Register *register)
    {
        write("%", register.index);
    }

    /** 
        Dumps type to console.

        Params:
            type = The type to be dumped.
    */
    void dump(ref Type type)
    {
        switch (type.kind)
        {
            case TypeKind.Void:
            {
                write("void");
                return;
            }

            case TypeKind.Integer:
            {
                write('i');
                break;
            }

            case TypeKind.Float:
            {
                write('f');
                break;
            }

            default:
                return;
        }

        write(type.size);
        
        if (type.isPointer)
        {
            for (ulong i = 0; i < type.count; ++i)
                write('*');
        }
        else if (type.count > 0)
            write('[', type.count, ']');
    }

    /** 
        Dumps instruction to console.

        Params:
            instruction = The instruction to be dumped.
    */
    void dump(ref Instruction instruction)
    {
        // Check for instruction kind.
        final switch (instruction.kind)
        {
            // <register> = <constant>;
            case InstructionKind.Assign:
            {
                dump(instruction.parameters[0]);
                write(": ");
                dump(instruction.type);
                write(" = ");
                dump(instruction.parameters[1]);
                writeln(";");
                break;
            }

            // <register> = <constant> + <constant>;
            case InstructionKind.Add:
            {
                dump(instruction.parameters[0]);
                write(": ");
                dump(instruction.type);
                write(" = ");
                dump(instruction.parameters[1]);
                write(" + ");
                dump(instruction.parameters[2]);
                writeln(";");
                break;
            }

            // return <constant>;
            case InstructionKind.Return:
            {
                write("return");

                if (instruction.parameters.length != 0)
                {
                    write(' ');
                    dump(instruction.parameters[0]);
                }

                writeln(";");
                break;
            }

            // console.output <register>;
            case InstructionKind.ConsoleOutput:
            {
                write("#console.output(");
                dump(instruction.parameters[0]);
                writeln(");");
                break;
            }
        }
    }

    /** 
        Dumps basic block to console.

        Params:
            basicBlock = The basic block to be dumped.
    */
    void dump(ref BasicBlock basicBlock)
    {
        writeln("@", basicBlock.index, ":");

        // Dump each instruction.
        foreach (ref Instruction instruction; basicBlock.instructions)
        {
            write("    ");
            dump(instruction);
        }
    }

    /// Dumps definition to console.
    void dump()
    {
        write(name, "(");
    
        for (uint index = 0; index < paratemerCount; ++index)
        {    
            dump(&registers[index]);
            write(": ");
            dump(registers[index].type);

            if (index != (paratemerCount - 1))
                write(", ");
        }

        write("): ");
        dump(type);
        writeln("\n{");

        // Dump each basic block.
        foreach (ref BasicBlock basicBlock; basicBlocks)
            dump(basicBlock);

        writeln("}");
    }
}