module compiler.frontend.scanner;

import compiler.frontend.token;
import compiler.common.file_location;

/// A structure that represents a scanner.
struct Scanner
{
    /// Points to the start of the token's content.
    const(char) *start;

    /// Points to the end of the token's content.
    const(char) *end;

    /// Points to the start of the line's content.
    const(char) *lineStart;

    /// The current line being scanned.
    ushort line;

    /// The current column being scanned.
    ushort column;

    /// The previously scanned token.
    Token previous;

    /// The current token that was scanned.
    Token current;

    /**
        Creates a scanner structure.

        Params:
            source = A pointer to the start of the source.
    */
    this(const(char) *source)
    {
        start     = source;
        end       = source;
        lineStart = source;
        line      = 1;
        column    = 1;
    }

    /**
        Advances current character.

        Returns:
            The current character that was advanced.
    */
    char advance()
    {
        ++column;
        ++end;

        return end[-1];
    }

    /**
        Matches current character?

        Params:
            expected = The expected character to match.

        Returns:
            true if both characters matches.
    */
    bool match(char expected)
    {
        if (*end == expected)
        {
            advance();
            return true;
        }

        return false;
    }

    /// Skips whitespace
    void skipWhitespace()
    {
        // Loop until the current character is not
        // a whitespace.
        for (;;)
        {
            switch (*end)
            {
                // Spacing?
                case ' ' :
                case '\t':
                case '\r':
                {
                    advance();
                    break;
                }

                // Line?
                case '\n':
                {
                    // Update line information
                    // NOTE: column = 0 because advance() will increase
                    // it.
                    column  = 0;
                    line   += 1;

                    // Set line start
                    lineStart = (end + 1);

                    advance();
                    break;
                }

                // Comment?
                case '/':
                {
                    // Is it a single line comment?
                    if (end[1] == '/')
                    {
                        while (*end != '\n' && *end != '\0')
                            advance();    
                    }
                    
                    // It isn't a comment, stop skiping.
                    else
                        return;

                    break;
                }

                // Not a whitespace?
                default:
                    return;
            }
        }
    }

    /** 
        Is current character a letter or underscore?

        Params:
            character = The character to check.

        Returns:
            true if current character is a letter or underscore.
    */
    bool isLetterOrUnderscore(char character)
    {
        return (character >= 'A' && character <= 'Z') ||
               (character >= 'a' && character <= 'z') ||
               (character == '_');
    }

    /** 
        Is current character a digit?

        Params:
            character = The character to check.

        Returns:
            true if current character is a digit.
    */
    bool isDigit(char character)
    {
        return (character >= '0' && character <= '9');
    }
    
    /**
        Creates token with kind.

        Params:
            kind = The kind of the token.

        Returns:
            The kind of the created token.
    */
    TokenKind makeToken(TokenKind kind)
    {
        current.kind      = kind;
        current.start     = start;
        current.location  = FileLocation(lineStart, line, column, (cast(ushort)(end - start)));

        return kind;
    }

    /**
        Creates token with error message.

        Params:
            message = The error message.

        Returns:
            The kind of the created token.
    */
    TokenKind makeToken(string message)
    {
        current.kind      = TokenKind.Error;
        current.start     = message.ptr;
        current.location  = FileLocation(lineStart, line, column, (cast(ushort)message.length));

        return TokenKind.Error;
    }

    /**
        Creates a number token.

        Returns:
            TokenKind.Integer if the scanned number was an integer or
            TokenKind.Float if the scanner number was a float.
    */
    TokenKind makeNumberToken()
    {
        // Loop until no digit left.
        while (isDigit(*end))
            advance();

        // Float?
        if (match('.'))
        {
            // Loop until no digit left.
            while (isDigit(*end))
                advance();

            // Make float token.
            return makeToken(TokenKind.Float);
        }

        // Make integer token.
        return makeToken(TokenKind.Integer);
    }

    /** 
        Creates a string token.

        Returns:
            TokenKind.String if the string was scanned correctly or
            TokenKind.Error if it failed to be scanned.
    */
    TokenKind makeStringToken()
    {
        // Loop until we find a '"' or null terminator.
        while (*end != '"' && *end != '\0')
            advance();

        // Is the current character a null terminator? If yes, then
        // it didn't scan the full string literal.
        if (*end == '\0')
            return makeToken("unterminated string.");

        // Advance the '"'.
        advance();
        return makeToken(TokenKind.String);
    }

    /** 
        Creates an identifier token.

        Returns:
            TokenKind.Identifier if the scanned token was an identifier,
            TokenKind.<keyword> if the scanned token was a keyword.
    */
    TokenKind makeIdentifierToken()
    {
        // Loop until no character, underscore or digit left.
        while (isDigit(*end) || isLetterOrUnderscore(*end))
            advance();
        
        // Check for keywords
        string identifierAsString = (cast(string)start[0 .. (end - start)]);

        if (identifierAsString == "Number" || identifierAsString == "String")
            return makeToken(TokenKind.Type);

        return makeToken(TokenKind.Identifier);
    }

    /**
        Scans next token.

        Returns:
            The kind of the scanned token.
    */
    TokenKind next()
    {
        // Skip all the whitespaces.
        skipWhitespace();

        // Move source position.
        start = end;

        // Set previous token.
        previous = current;

        // Is source end?
        if (*end == '\0')
            return makeToken(TokenKind.End);

        // Scan next character.
        char character = advance();

        // Is character a digit?
        if (isDigit(character))
            return makeNumberToken();

        // Is character a letter or underscore?
        if (isLetterOrUnderscore(character))
            return makeIdentifierToken();

        // Check for other characters.
        switch (character)
        {
            case '(':
                return makeToken(TokenKind.LeftParenthesis);

            case ')':
                return makeToken(TokenKind.RightParenthesis);
                
            case '{':
                return makeToken(TokenKind.LeftBrace);
                
            case '}':
                return makeToken(TokenKind.RightBrace);
                
            case ',':
                return makeToken(TokenKind.Comma);
                
            case '.':
                return makeToken(TokenKind.Dot);
                
            case '+':
                return makeToken(TokenKind.Plus);
                
            case '-':
            {
                // ->
                if (match('>'))
                    return makeToken(TokenKind.Arrow);

                return makeToken("expected '->' token.");
            }

            case '"':
                return makeStringToken();

            // Unexpected character.
            default:
                return makeToken("unexpected character.");
        }
    }
}