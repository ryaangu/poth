module compiler.common.ir.register;

import compiler.common.ir.type;

/// A structure that represents an Intermediate Representation register.
struct Register
{
    /// The index of the register.
    uint index;

    /// The type of the register.
    Type type;
}