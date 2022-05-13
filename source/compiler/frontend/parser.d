module compiler.frontend.parser;

import compiler.common.source_file;
import compiler.frontend.scanner;
import compiler.frontend.token;
import compiler.common.nodes;
import compiler.common.ir.type;
import std.stdio;
import std.conv;
import config;

/// A structure that represents a parser.
struct Parser
{
    /// The current source file being parsed.
    SourceFile *sourceFile;

    /// The current scanner being used.
    Scanner *scanner;

    /// Advances the current token.
    void advance()
    {
        // Do a loop, if we find an error token,
        // handle that error and keep doing that until we find 
        // a valid token.
        for (;;)
        {
            // Is the current token an error token?
            if (scanner.next() != TokenKind.Error)
                break;

            sourceFile.error(scanner.current.location, scanner.current.asString(0, 0));
        }
    }

    /** 
        Matches current token kind?

        Params:
            expected = The expected kind to match.

        Returns:
            true if both kinds matches.
    */
    bool match(TokenKind expected)
    {
        // Are both kinds the same?
        if (scanner.current.kind == expected)
        {
            // Advance the current token.
            advance();
            return true;
        }

        // Not the same.
        return false;
    }

    /**
        Consumes current token.

        Params:
            expected = The expected kind to consume.
            message  = The error message if kinds don't match.
    */
    void consume(TokenKind expected, string message)
    {
        // Matches current token kind?
        if (match(expected))
            return;

        // Didn't match current token kind.
        sourceFile.error(scanner.current.location, message);
    }

    /** 
        Parses statement.

        Returns:
            The parsed node or null if an error happened.
    */
    Node parseStatement()
    {
        // Advance the current token, so we can parse easily.
        advance();

        // Check for previous token kind.
        switch (scanner.previous.kind)
        {
            // Float literal.
            case TokenKind.Float:
                return new NodeFloat(scanner.previous.location, 
                                     to!(float)(scanner.previous.asString(0, 0)));

            // Integer literal.
            case TokenKind.Integer:
                return new NodeInteger(scanner.previous.location, 
                                       to!(long)(scanner.previous.asString(0, 0)));

            // String literal.
            case TokenKind.String:
                return new NodeString(scanner.previous.location, 
                                      scanner.previous.asString(1, 1));

            // Binary addition.
            case TokenKind.Plus:
                return new NodeOperator(scanner.previous.location, 
                                        OperatorKind.Add);

            // Console output.
            case TokenKind.Dot:
                return new NodeOperator(scanner.previous.location, 
                                        OperatorKind.ConsoleOutput);

            // Unexpected token.
            default:
            {
                sourceFile.error(scanner.previous.location, "unexpected token.");
                return null;
            }
        }
    }

    /// Parses type.
    Node parseType()
    {
        // Get the type name.
        string typeName = scanner.previous.asString(0, 0);

        // Check for the type.
        final switch (typeName)
        {
            case "String":
                return new NodeType(scanner.previous.location, TypeKind.String);

            case "Number":
                return new NodeType(scanner.previous.location, TypeKind.Number);
        }
    }

    /** 
        Parses function declaration.

        Params:
            name = The function name token.
    */
    void parseFunction(Token name)
    {
        // Build the node.
        NodeFunction node = new NodeFunction();
        node.location     = name.location;
        node.name         = name;

        // Parse function effects.
        if (!match(TokenKind.RightParenthesis))
        {
            if (!match(TokenKind.Arrow))
            {
                do
                {
                    // Expect type name.
                    consume(TokenKind.Type, "expected type.");
                    node.inputs ~= parseType();
                }
                while (match(TokenKind.Comma));
            }
            
            if (scanner.previous.kind == TokenKind.Arrow || match(TokenKind.Arrow))
            {
                consume(TokenKind.Type, "expected type after '->'.");
                node.output = parseType();
            }
            else 
                node.output = null;

            consume(TokenKind.RightParenthesis, "expected ')' after function effects.");
        }

        // Parse function body.
        consume(TokenKind.LeftBrace, "expected '{' after ')'.");

        while (!match(TokenKind.RightBrace) && !match(TokenKind.End))
        {
            // Parse statement and add to node.
            node.statements ~= parseStatement();
        }

        if (scanner.previous.kind != TokenKind.RightBrace)
            sourceFile.error(scanner.previous.location, "expected '}'.");

        // Add the node to file nodes.
        sourceFile.nodes ~= node;
    }

    /// Parses declaration.
    void parseDeclaration()
    {
        // Advance the current token, so we can parse easily.
        advance();

        // Check for previous token kind.
        switch (scanner.previous.kind)
        {
            // Function declaration?
            case TokenKind.Identifier:
            {
                // Save the identifier
                Token identifier = scanner.previous;

                // Make sure it's a function
                if (match(TokenKind.LeftParenthesis))
                    parseFunction(identifier);
                else
                    goto default;

                break;
            }

            // Unexpected token.
            default:
            {
                sourceFile.error(scanner.previous.location, "unexpected token.");
                break;
            }
        }
    }

    /// Starts parsing the source files.
    void start()
    {
        // Parse all the source files into Abstract Syntax Trees.
        foreach (ref SourceFile file; gSourceFiles)
        {
            // Set current source file and scanner.
            sourceFile = &file;
            scanner    = &file.scanner;

            // Advance one token, so we can parse easily.
            advance();
        
            // Loop until source end.
            while (!match(TokenKind.End))
            {
                // Parse declaration.
                parseDeclaration();
            }
        }

        // Check for errors before semantic analysis
        if (gHasFatalErrors)
            return;

        /*
            Analyze all the nodes.
        */

        // Foward declaration pass.
        foreach (ref SourceFile file; gSourceFiles)
        {
            foreach (ref Node node; file.nodes)
                node.declare(file);
        }

        // Other analysis
        foreach (ref SourceFile file; gSourceFiles)
        {
            // Type checking pass.
            foreach (ref Node node; file.nodes)
                node.typeCheck(file);
        }
    }
}