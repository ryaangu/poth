module moon.scanner;

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
}

struct Token
{
    TokenKind kind;
    string    content;
    uint      line;
    uint      column;    
}

struct Scanner
{
    Token previous;
    Token current;

    string source;

    uint line;
    uint column;
    
    uint start;
    uint end;

    this(string _source)
    {
        source   = _source;
        line     = 1;
        column   = 1;
        start    = 0;
        end      = 0;
    }

    char advance()
    {
        ++end;
        ++column;

        return source[end - 1];
    }

    bool match(char expected)
    {
        if (source[end] == expected)
        {
            advance();
            return true;
        }

        return false;
    }

    TokenKind make_token(TokenKind kind)
    {
        current.kind    = kind;
        current.content = source[start .. end];
        current.line    = line;
        current.column  = column;

        return kind;
    }

    TokenKind make_token(string message)
    {
        current.kind    = TokenKind.Error;
        current.content = message;
        current.line    = line;
        current.column  = column;

        return TokenKind.Error;
    }

    void skip_whitespace()
    {
        for (;;)
        {
            switch (source[end])
            {
                case ' ':
                case '\t':
                case '\r':
                {
                    advance();
                    break;
                }

                case '\n':
                {
                    advance();

                    line   += 1;
                    column  = 0;
                
                    break;
                }

                case '/':
                {
                    if (source[end + 1] == '/')
                    {
                        while (!match('\n') && source[end] != '\0')
                            advance();
                    }
                    else
                        return;

                    break;
                }

                default:
                    return;
            }
        }
    }

    bool is_number(char character)
    {
        return (character >= '0' && character <= '9');
    }

    TokenKind make_number_token()
    {
        while (is_number(source[end]))
            advance();

        if (match('.'))
        {
            while (is_number(source[end]))
                advance();

            return make_token(TokenKind.Float);
        }

        return make_token(TokenKind.Integer);
    }

    TokenKind scan()
    {
        skip_whitespace();

        previous = current;
        start    = end;

        if (source[end] == '\0')
            return make_token(TokenKind.End);

        char character = advance();

        if (is_number(character))
            return make_number_token();

        switch (character) 
        {
            case '+':
                return make_token(TokenKind.Plus);

            case '.':
                return make_token(TokenKind.Dot);

            default:
                return make_token("unexpected character.");
        }
    }
}