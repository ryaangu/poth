module compiler.frontend.parser;

import compiler.input;
import compiler.config;

import compiler.frontend.scanner;
import compiler.frontend.token;
import compiler.frontend.node;

import std.stdio;
import std.conv;

struct Parser
{
    Input *input;
    Scanner *scanner;

    void advance()
    {
        for (;;)
        {
            if (scanner.scan() != TokenKind.Error)
                break;

            // error
        }
    }

    bool match(TokenKind expected)
    {
        if (scanner.current.kind == expected)
        {
            advance();
            return true;
        }

        return false;
    }

    void consume(TokenKind kind, string message)
    {
        if (match(kind))
            return;

        // error
    }

    Node statement()
    {
        advance();

        switch (scanner.previous.kind)
        {
            case TokenKind.Integer:
                return new NodeInteger(to!(long)(scanner.previous.content));

            case TokenKind.Float:
                return new NodeFloat(to!(double)(scanner.previous.content));

            case TokenKind.String:
                return new NodeString(scanner.previous.content[1 .. $ - 1]);
                
            case TokenKind.Identifier:
                return new NodeIdentifier(scanner.previous.content);
                
            case TokenKind.Dot:
                return new NodeConsoleOutput();

            case TokenKind.Plus:
                return new NodeAdd();

            default:
                return null;
        }
    }

    void function_declaration()
    {
        NodeFunction node = new NodeFunction();
        node.name = scanner.previous.content;

        consume(TokenKind.LeftParenthesis, "expected '('.");

        if (!match(TokenKind.RightParenthesis))
        {
            do
            {
                if (match(TokenKind.Arrow))
                    node.out_effects ~= statement();
                else
                    node.in_effects ~= statement();
            }
            while (match(TokenKind.Comma));

            consume(TokenKind.RightParenthesis, "expected ')'.");
        }

        consume(TokenKind.LeftBrace, "expected '{'.");

        while (!match(TokenKind.RightBrace) && !match(TokenKind.End))
        {
            node.statements ~= statement();
        }

        // if (scanner.previous.kind == TokenKind.End)
            // error

        input.nodes ~= node;
    }

    void parse()
    {
        advance();
        
        switch (scanner.previous.kind)
        {
            case TokenKind.Identifier:
            {
                function_declaration();
                break;
            }

            default:
                break;
        }
    }

    void start()
    {
        foreach (ref Input _input; g_inputs)
        {
            input = &_input;
            scanner = &input.scanner;
            advance();

            while (!match(TokenKind.End))
                parse();
        }
    }
}