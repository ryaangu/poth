module compiler.common.nodes.node_type;

import compiler.common.nodes.node;
import compiler.common.source_file;
import compiler.common.file_location;
import compiler.common.ir;
import compiler.frontend.token;

/// A class that represents a type node.
class NodeType : Node
{
    /// The kind of the type.
    TypeKind kind;

    /**
        Creates a type node class.

        Params:
            location = The location of the node in the file.
            kind     = The type kind.
    */
    this(FileLocation location, TypeKind kind)
    {
        this.location = location;
        this.kind     = kind;
    }

    /**
        Type checking pass.

        Params:
            file = The source file the node is in.
    */
    override Type typeCheck(ref SourceFile file)
    {
        switch (kind)
        {
            case TypeKind.String:
                return Type(TypeKind.Integer, 8, 1, true);

            case TypeKind.Number:
                return Type(TypeKind.Integer, 32, 0, false);

            default:
                return Type(TypeKind.Void);
        }
    }
}