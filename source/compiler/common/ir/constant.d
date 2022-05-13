module compiler.common.ir.constant;

import compiler.common.ir.register;
import compiler.common.ir.type;

/// The kind of a constant.
enum ConstantKind
{
    Integer,
    Float,
    String,
    Register,
}

/// A structure that represents an Intermediate Representation constant.
struct Constant
{
    /// An union with the constant value.
    union
    {
        /// The constant value as integer.
        long asInteger;

        /// The constant value as float.
        double asFloat;

        /// The constant value as string.
        string asString;

        /// The constant value points to a register.
        Register *asRegister;
    }

    /// The kind of the constant.
    ConstantKind kind;

    /// The type of the constant.
    Type type;

    /**
        Creates an integer constant.
    
        Params:
            value = The integer value.
    */
    this(long value)
    {
        asInteger = value;
        kind      = ConstantKind.Integer;
        type      = Type(TypeKind.Integer, 32, 1);
    }

    /**
        Creates a float constant.
    
        Params:
            value = The float value.
    */
    this(float value)
    {
        asFloat = value;
        kind    = ConstantKind.Float;
        type    = Type(TypeKind.Float, 32, 1);
    }

    /**
        Creates a string constant.
    
        Params:
            value = The string value.
    */
    this(string value)
    {
        asString = value;
        kind     = ConstantKind.String;
        type     = Type(TypeKind.Integer, 8, value.length);
    }

    /**
        Creates a register constant.
    
        Params:
            value = The register value.
    */
    this(Register *value)
    {
        asRegister = value;
        kind       = ConstantKind.Register;
        type       = value.type;
    }
}