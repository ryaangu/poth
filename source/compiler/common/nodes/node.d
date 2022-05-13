module compiler.common.nodes.node;

import compiler.common.ir.type;
import compiler.common.source_file;
import compiler.common.file_location;

/// A class that represents an Abstract Syntax Tree node.
class Node
{
    /// The location of the node in the file.
    FileLocation location;

    /** 
        Forward declaration pass.

        Params:
            file = The source file the node is in.
    */
    void declare(ref SourceFile file)
    {

    }

    /**
        Type checking pass.

        Params:
            file = The source file the node is in.
    */
    Type typeCheck(ref SourceFile file)
    {
        return Type(TypeKind.Void);
    }

    /**
        IR generation pass.

        Params:
            file = The source file the node is in.
    */
    void emit(ref SourceFile file)
    {

    }
}