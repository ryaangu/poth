module compiler.frontend.token;

enum TokenKind
{
    End,
    Error,

    Identifier,
    Integer,
    Float,
    String,

    Plus,
    Dot,

    LeftParenthesis,
    RightParenthesis,
    LeftBrace,
    RightBrace,
    Comma,

    Arrow,

    Function,
}

struct Token
{
    TokenKind kind;
    string content;
    uint line;
    uint column;    
}