module compiler.common.ir.basic_block;

import compiler.common.ir.instruction;

/// A structure that represents an Intermediate Representation basic block.
struct BasicBlock
{
    /// The index of the basic block.
    uint index;

    /// All the instructions inside this basic block.
    Instruction[] instructions;
}