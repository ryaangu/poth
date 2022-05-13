module compiler.common.nodes.node_operator;

import compiler.common.nodes.node;
import compiler.common.source_file;
import compiler.common.file_location;
import compiler.common.ir;
import compiler.frontend.token;

/// The kind of an operator.
enum OperatorKind
{
    Add,
    ConsoleOutput,
}

/// A class that represents an operator node.
class NodeOperator : Node
{
    /// The operation kind.
    OperatorKind kind;

    /**
        Creates an operator node class.

        Params:
            location = The location of the node in the file.
            operator = The operator kind.
    */
    this(FileLocation location, OperatorKind operator)
    {
        this.location = location;
        kind          = operator;
    }

    /**
        Type checking pass.

        Params:
            file = The source file the node is in.
    */
    override Type typeCheck(ref SourceFile file)
    {
        // Check for operator
        final switch (kind)
        {
            // Add operation. (needs 2 stack values)
            case OperatorKind.Add:
            {
                if (file.typeStack.length < 2)
                    file.error(location, "expected 2 stack values for add operation.");
                else
                {
                    // TODO: Get highest type
                    Type result = file.typeStack[$ - 1];

                    // Remove the 2 values
                    file.typeStack.length -= 2;
                    file.nodeStack.length = 0;

                    // Add result type
                    file.typeStack ~= result;
                    file.nodeStack ~= this;
                }

                break;
            }

            // Console Output operation. (needs 1 stack value)
            case OperatorKind.ConsoleOutput:
            {
                if (file.typeStack.length < 1)
                    file.error(location, "expected 1 stack value for console output operation.");
                else
                {
                    // Remove value
                    file.typeStack.length -= 1;
                    file.nodeStack.length -= (file.nodeStack.length > 0) ? 1 : 0;
                }

                break;
            }
        }

        return Type(TypeKind.Void);
    }

    /**
        IR generation pass.

        Params:
            file = The source file the node is in.
    */
    override void emit(ref SourceFile file)
    {
        // Check for operator kind.
        final switch (kind)
        {
            // Add operation.
            case OperatorKind.Add:
            {
                // Check for stack 
                if (file.registerStack.length < 2) {}
                // TODO: error
                else
                {
                    // Get both operands
                    Register *b = file.registerStack[$ - 1];
                    --file.registerStack.length;
                    Register *a = file.registerStack[$ - 1];
                    --file.registerStack.length;

                    // Make a destination register.
                    Register *register = file.definition.addRegister(a.type);
                    
                    // Add register to stack.
                    file.registerStack ~= register;

                    // Emit add instruction.
                    file.definition.addInstruction(Instruction(
                        InstructionKind.Add,
                        a.type,
                        [
                            Constant(register),
                            Constant(a),
                            Constant(b),
                        ],
                    ));
                }
                break;
            }

            // Console output operation.
            case OperatorKind.ConsoleOutput:
            {
                // Check for stack 
                // if (file.registerStack.length < 2)
                // TODO: error
                // else
                {
                    // Get stack value
                    Register *value = file.registerStack[$ - 1];
                    --file.registerStack.length;
                    
                    // Emit console output instruction.
                    file.definition.addInstruction(Instruction(
                        InstructionKind.ConsoleOutput,
                        Type(TypeKind.Void, 0, 0),
                        [
                            Constant(value),
                        ],
                    ));
                }
                break;
            }
        }
    }
}