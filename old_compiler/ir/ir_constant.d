module compiler.ir.ir_constant;

import compiler.ir.ir_type;

enum IR_ConstantKind
{
    Integer,
    Float,
    String,
    Register,
}

struct IR_Constant
{
    union
    {
        long as_integer;
        double as_float;
        string as_string;
        uint as_register;
    }

    IR_ConstantKind kind;
    IR_Type type;

    this(long value)
    {
        as_integer = value;
        kind = IR_ConstantKind.Integer;
        type = IR_Type(IR_TypeKind.Integer, 32);
    }

    this(double value)
    {
        as_float = value;
        kind = IR_ConstantKind.Float;
        type = IR_Type(IR_TypeKind.Float, 32);
    }

    this(string value)
    {
        as_string = value;
        kind = IR_ConstantKind.String;
        type = IR_Type(IR_TypeKind.String, value.length);
    }

    this(uint value)
    {
        as_register = value;
        kind = IR_ConstantKind.Register;
        type = IR_Type(IR_TypeKind.Integer, 32);
    }
}