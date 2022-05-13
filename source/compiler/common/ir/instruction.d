module compiler.common.ir.instruction;

import compiler.common.ir.constant;
import compiler.common.ir.register;
import compiler.common.ir.type;

/// The kind of an instruction.
enum InstructionKind
{
    /// Assign a constant to register.
    Assign,

    /// Adds two constants and assigns the result to register.
    Add,

    /// Return a constant or nothing.
    Return,

    /// Writes constant to output.
    ConsoleOutput,

    /// Calls definition with constant parameters, first parameter is null if no destination.
    // Call,
}

/// A structure that represents an Intermediate Representation instruction.
struct Instruction
{
    /// The kind of the instruction.
    InstructionKind kind;

    /// The result type of the instruction.
    Type type;

    /// The instruction parameters.
    Constant[] parameters;
}