module compiler.common.ir.type;

/// The kind of a type.
enum TypeKind
{
    Void,
    Integer,
    Float,

    // AST specific
    Number,
    String,
}

/// A structure that represents an Intermediate Representation type.
struct Type
{
    TypeKind kind;
    uint     size;
    ulong    count;
    bool     isPointer; 

    /* 
        Compare types

        Params:
            other = The other type to compare.
    */
    bool compare(ref Type other)
    {
        return ((other.kind      == kind     ) && 
                (other.isPointer == isPointer) &&
                (other.count     == count    ));
    }

    /// Get type name 
    string getName()
    {
        if (kind == TypeKind.Void)
            return "Void";
        else if (kind == TypeKind.Integer && size == 8 && count > 0)
            return "String";
        else
            return "Number";
    }
}