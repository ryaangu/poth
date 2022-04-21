module compiler.ir.ir_type;

enum IR_TypeKind
{
    Integer,
    Float,
    String,
}

struct IR_Type
{
    IR_TypeKind kind;
    ulong size;
}