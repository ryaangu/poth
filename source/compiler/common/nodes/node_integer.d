module compiler.common.nodes.node_integer;

import compiler.common.nodes.node;
import compiler.common.source_file;
import compiler.common.file_location;
import compiler.common.ir;
import compiler.frontend.token;

/// A class that represents an integer literal node.
class NodeInteger : Node
{
    /// The integer value.
    long value;

    /**
        Creates an integer node class.

        Params:
            location = The location of the node in the file.
            value    = The integer value.
    */
    this(FileLocation location, long value)
    {
        this.location = location;
        this.value    = value;
    }

    /**
        Type checking pass.

        Params:
            file = The source file the node is in.
    */
    override Type typeCheck(ref SourceFile file)
    {
        Type type = Type(TypeKind.Integer, 32, 0, false);
        
        file.typeStack ~= type;
        file.nodeStack ~= this;
        
        return type;
    }

    /**
        IR generation pass.

        Params:
            file = The source file the node is in.
    */
    override void emit(ref SourceFile file)
    {
        // Make a new register.
        Register *register = file.definition.addRegister(typeCheck(file));
        
        // Add register to stack.
        file.registerStack ~= register;

        // Assign value to register.
        file.definition.addInstruction(Instruction(
            InstructionKind.Assign,
            typeCheck(file),
            [
                Constant(register),
                Constant(value),
            ],
        ));
    }
}