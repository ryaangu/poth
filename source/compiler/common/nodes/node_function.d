module compiler.common.nodes.node_function;

import compiler.common.nodes.node;
import compiler.common.source_file;
import compiler.common.file_location;
import compiler.common.ir;
import compiler.frontend.token;

import std.conv;

/// A class that represents a function declaration node.
class NodeFunction : Node
{
    /// The name of the function.
    Token name;

    /// The input effects of the function.
    Node[] inputs;

    /// The output effect of the function.
    Node output;

    /// The function body.
    Node[] statements;

    /** 
        Forward declaration pass.

        Params:
            file = The source file the node is in.
    */
    override void declare(ref SourceFile file)
    {

    }

    /**
        Type checking pass.

        Params:
            file = The source file the node is in.
    */
    override Type typeCheck(ref SourceFile file)
    {
        // Add parameters.
        foreach (ref Node parameter; inputs)
        {
            file.nodeStack ~= parameter;
            file.typeStack ~= parameter.typeCheck(file);
        }

        // Type check all statements.
        foreach (ref Node statement; statements)
            statement.typeCheck(file);

        // Get function type.
        Type type = (output) ? output.typeCheck(file)
                             : Type(TypeKind.Void);

        // Type check the return value
        Type lastValue = (file.typeStack.length > 0) ? file.typeStack[$ - 1]
                                                     : Type(TypeKind.Void);

        if (!type.compare(lastValue))
            file.error(file.nodeStack[$ - 1].location, 
                       "return value type (" ~
                       lastValue.getName() ~
                       ") doesn't match function return type (" ~
                       type.getName() ~ ").");

        return type;
    }

    /**
        IR generation pass.

        Params:
            file = The source file the node is in.
    */
    override void emit(ref SourceFile file)
    {
        // Get function name.
        string nameAsString = name.asString(0, 0);

        // Get function type.
        Type type = (output) ? output.typeCheck(file)
                             : Type(TypeKind.Void);

        // Make function definition.
        file.definitions[nameAsString] = Definition(nameAsString, 
                                                    type,
                                                    cast(uint)inputs.length);

        // Set current definition.
        file.definition = &(file.definitions[nameAsString]);

        // Make parameter registers
        foreach (Node input; inputs)
        {
            // Make a new register.
            Register *register = file.definition.addRegister(input.typeCheck(file));
            
            // Add register to stack.
            file.registerStack ~= register;
        }

        // Make entry basic block.
        file.definition.addBasicBlock();

        // Emit the statements.
        foreach (ref Node statement; statements)
            statement.emit(file);

        // Check for stack, if not empty, return the "last" value.
        if (file.registerStack.length != 0)
        {
            // Pop the register from it.
            Register *register = file.registerStack[$ - 1];
            --file.registerStack.length;

            // Emit return instruction.
            file.definition.addInstruction(Instruction(
                InstructionKind.Return,
                file.definition.registers[register.index].type,
                [
                    Constant(register),
                ],
            ));
        }
        
        // Empty, return nothing.
        else
        {
            // Emit return instruction.
            file.definition.addInstruction(Instruction(InstructionKind.Return, Type(TypeKind.Void)));
        }
    }
}