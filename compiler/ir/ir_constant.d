module compiler.ir.ir_constant;

enum IR_ConstantKind
{
    Integer,
    Float,
    Register,
}

struct IR_Constant
{
    union
    {
        long as_integer;
        double as_float;
        uint as_register;
    }

    IR_ConstantKind kind;

    this(long value)
    {
        as_integer = value;
        kind = IR_ConstantKind.Integer;
    }

    this(double value)
    {
        as_float = value;
        kind = IR_ConstantKind.Float;
    }

    this(uint value)
    {
        as_register = value;
        kind = IR_ConstantKind.Register;
    }
}