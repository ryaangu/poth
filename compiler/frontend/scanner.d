module compiler.frontend.scanner;

import compiler.frontend.token;

struct Scanner
{
    Token previous;
    Token current;

    string source;

    uint line;
    uint column;
    
    uint start;
    uint end;

    TokenKind[string] keywords;

    this(string _source)
    {
        source   = _source;
        line     = 1;
        column   = 1;
        start    = 0;
        end      = 0;

        keywords["function"] = TokenKind.Function;
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

    bool is_letter_or_underscore(char character)
    {
        return (character >= 'A' && character <= 'Z') ||
               (character >= 'a' && character <= 'z') ||
               (character == '_');
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

    TokenKind make_identifier_token()
    {
        while (is_letter_or_underscore(source[end]) || is_number(source[end]))
            advance();

        string name = source[start .. end];

        if (name in keywords)
            return make_token(keywords[name]);

        return make_token(TokenKind.Identifier);
    }

    TokenKind make_string_token()
    {
        while (source[end] != '"' && source[end] != '\0')
            advance();

        if (source[end] == '\0')
            return make_token("unterminated string.");

        advance();
        return make_token(TokenKind.String);
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

        if (is_letter_or_underscore(character))
            return make_identifier_token();

        switch (character) 
        {
            case '+':
                return make_token(TokenKind.Plus);

            case '.':
                return make_token(TokenKind.Dot);

            case '(':
                return make_token(TokenKind.LeftParenthesis);

            case ')':
                return make_token(TokenKind.RightParenthesis);

            case '{':
                return make_token(TokenKind.LeftBrace);

            case '}':
                return make_token(TokenKind.RightBrace);

            case ',':
                return make_token(TokenKind.Comma);

            case '-':
            {
                if (match('>'))
                    return make_token(TokenKind.Arrow);

                return make_token("expected '->'.");
            }

            case '"':
                return make_string_token();

            default:
                return make_token("unexpected character.");
        }
    }
}