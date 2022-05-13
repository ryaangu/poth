module compiler.frontend.token;

import compiler.common.file_location;

/// The kind of a token.
enum TokenKind
{
    /// End of file.
    End,

    /// Scanner Error.
    Error,

    /// [A-Z-a-z-_]
    Identifier,

    /// [0-9]
    Integer,

    /// [[0-9].[0-9]]
    Float,

    /// ["*"]
    String,

    /// (
    LeftParenthesis,

    /// )
    RightParenthesis,

    /// {
    LeftBrace,

    /// }
    RightBrace,

    /// ,
    Comma,

    /// .
    Dot,

    /// +
    Plus,

    /// ->
    Arrow,

    /// Number || String
    Type,
}

/// A structure that represents a token.
struct Token
{
    /// The kind of the token.
    TokenKind kind;

    /// Points to the start of the content.
    const(char) *start;

    /// The location of the token in the file.
    FileLocation location;

    /**
        Get token content as string.

        Returns:
            a string with the content.
    */
    string asString(int start, int end)
    {
        return (cast(string)(this.start[start .. location.length - end]));
    }
}