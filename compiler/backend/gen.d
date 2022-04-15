module compiler.backend.gen;

import compiler.frontend.scanner;
import compiler.backend.ir;

import std.conv;
import std.stdio;

struct Generator
{
    Scanner scanner = Scanner("1 2 3 + + .\0");

    IRLabel label;
    
    int stack_count = 0;

    void advance()
    {
        for (;;)
        {
            if (scanner.scan() != TokenKind.Error)
                break;

            // error
        }
    }

    bool match(TokenKind kind)
    {
        if (scanner.current.kind == kind)
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

    IRConstant push(IRConstant constant)
    {
        ++stack_count;
        label.set(label.variable(), constant);
        return constant;
    }

    IRConstant pop()
    {
        if ((stack_count--) == 0)
            writeln("tried to pop nothing.");

        return IRConstant(label.variable_count - (stack_count + 1));
    }

    void generate()
    {
        advance();

        switch (scanner.previous.kind)
        {
            case TokenKind.Integer:
            case TokenKind.Float:
            {
                push(IRConstant(to!(double)(scanner.previous.content)));
                break;
            }

            case TokenKind.Plus:
            {
                IRConstant b = pop();
                IRConstant a = pop();

                ++stack_count;
                label.add(label.variable(), a, b);
                break;
            }

            case TokenKind.Dot:
            {
                IRConstant a = pop();
                label.cout(a);
                break;
            }

            default:
                break;
        }
    }

    void start()
    {
        advance();

        while (!match(TokenKind.End))
            generate();
    }
}