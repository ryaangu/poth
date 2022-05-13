module compiler.backend.c.emitter;

import compiler.common.ir;
import compiler.common.source_file;
import compiler.backend.c.output;
import config;

import std.string;
import std.conv;
import std.uni;

/// A structure that emits C code.
struct C_Emitter
{
    /// All the C output from source files.
    C_Output[string] outputs;

    /// The current C output being used.
    C_Output *output;

    /// Starts emitting C code.
    void start()
    {
        // Loop through each source file.
        foreach (ref SourceFile file; gSourceFiles)
        {
            // Set output to be used.
            outputs[file.path] = C_Output();
            output = &outputs[file.path];

            // Make header identifier
            string headerIdentifier = to!(string)(asUpperCase(file.path))
                                                  .replace("/",    "_" )
                                                  .replace(".PTH", "_H");

            // #ifndef <header identifier>
            output.header ~= ("#ifndef " ~ headerIdentifier ~ '\n');
            
            // #define <header identifier>
            output.header ~= ("#define " ~ headerIdentifier ~ "\n\n");

            // #include <poth.h>
            output.header ~= "#include <poth.h>\n\n";

            // Emit all definitions
            foreach (ref Definition definition; file.definitions)
                emit(definition);

            // #endif
            output.header ~= "\n#endif";

            import std.stdio;

            writeln(output.header);
            writeln(output.source);
        }
    }

    /** 
        Get type as C type.

        Params:
            type = The type to get as C type.
    */
    string asCType(ref Type type)
    {
        string cType;

        switch (type.kind)
        {
            case TypeKind.Void:
                return "void";

            case TypeKind.Integer:
            {
                if (type.size == 8 && type.count > 0)
                    return "string_t";

                cType = "int";
                break;
            }

            case TypeKind.Float:
            {
                cType = "float";
                break;
            }

            default:
                return "<error>";
        }

        cType ~= to!(string)(type.size);
        cType ~= "_t";
        
        if (type.isPointer)
        {
            cType ~= ' ';

            for (ulong i = 0; i < type.count; ++i)
                cType ~= '*';
        }
        else if (type.count > 0)
            cType ~= ('[' ~ to!(string)(type.count) ~ ']');

        return cType;
    }

    /** 
        Emits constant to source.

        Params:
            constant = The constant to be emitted.
    */
    string asString(ref Constant constant)
    {
        // Check for constant kind.
        final switch (constant.kind)
        {
            // Integer
            case ConstantKind.Integer:
                return to!(string)(constant.asInteger);

            // Float
            case ConstantKind.Float:
                return to!(string)(constant.asFloat);

            // String
            case ConstantKind.String:
                return ('"' ~ constant.asString ~ '"');

            // Register
            case ConstantKind.Register:
                return ('R' ~ to!(string)(constant.asRegister.index));
        }
    }

    /** 
        Emits instruction to source.

        Params:
            instruction = The instruction to be emitted.
    */
    void emit(ref Instruction instruction)
    {
        // Check for instruction kind.
        final switch (instruction.kind)
        {
            // <type> <register> = <constant>;
            case InstructionKind.Assign:
            {
                // Get register.
                Constant register = instruction.parameters[0];

                // Get constant.
                Constant constant = instruction.parameters[1];

                // <type> <register>
                output.source ~= asCType(register.type);
                output.source ~= ' ';
                output.source ~= asString(register);

                // = <constant>;
                output.source ~= " = ";
                output.source ~= asString(constant);
                output.source ~= ";\n";
                break;
            }

            // <type> <register> = <constant> + <constant>;
            case InstructionKind.Add:
            {
                // Get register.
                Constant register = instruction.parameters[0];

                // Get a and b.
                Constant a = instruction.parameters[1];
                Constant b = instruction.parameters[2];

                // <type> <register>
                output.source ~= asCType(register.type);
                output.source ~= ' ';
                output.source ~= asString(register);

                // = <a> + <b>;
                output.source ~= " = ";
                output.source ~= asString(a);
                output.source ~= " + ";
                output.source ~= asString(b);
                output.source ~= ";\n";
                break;
            }

            // return <constant>;
            case InstructionKind.Return:
            {
                // <return>;
                if (instruction.parameters.length == 0)
                    output.source ~= "return;\n";
                else
                {
                    // Get constant.
                    Constant constant = instruction.parameters[0];

                    // <return> <constant>;
                    output.source ~= "return ";
                    output.source ~= asString(constant);
                    output.source ~= ";\n";
                }
                break;
            }

            // poth_print_<type>(<register>);
            case InstructionKind.ConsoleOutput:
            {
                // Get register
                Constant register = instruction.parameters[0];

                // poth_print_<type>
                output.source ~= "poth_print_";
                output.source ~= asCType(register.asRegister.type);

                // (<register>);
                output.source ~= '(';
                output.source ~= asString(register);
                output.source ~= ");\n";
                break;
            }
        }
    }

    /** 
        Emits basic block to source.

        Params:
            basicBlock = The basic block to be emitted.
    */
    void emit(ref BasicBlock basicBlock)
    {
        output.source ~= ("BB" ~ to!(string)(basicBlock.index) ~ ":\n");

        // <statement...>
        foreach (ref Instruction instruction; basicBlock.instructions)
        {
            output.source ~= '\t';
            emit(instruction);
        }
    }

    /// Emits definition to header and source contents.
    void emit(ref Definition definition)
    {
        /*
            Generate function head.
        */
        string functionHead;

        // <type> <mangled name (TODO)>
        functionHead ~= asCType(definition.type);
        functionHead ~= ' ';
        functionHead ~= definition.name;

        // (<parameter..., >)
        functionHead ~= '(';

        for (uint index = 0; index < definition.paratemerCount; ++index)
        {
            // Get register
            Constant register = Constant(&definition.registers[index]);

            // <type> <name>
            functionHead ~= asCType(register.type);
            functionHead ~= ' ';
            functionHead ~= asString(register);

            // ,
            if (index != (definition.paratemerCount - 1))
                functionHead ~= ", ";
        }

        functionHead ~= ')';

        /* 
            Emit to header and source.
        */

        // <type> <mangled name> (<parameter..., >);
        output.header ~= (functionHead ~ ";\n");

        // <type> <mangled name> (<parameter..., >) { <statement...> }
        output.source ~= (functionHead ~ "\n{\n");

        foreach (ref BasicBlock basicBlock; definition.basicBlocks)
            emit(basicBlock);

        output.source ~= "}\n";
    }
}