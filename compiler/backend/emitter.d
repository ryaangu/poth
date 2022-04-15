module compiler.backend.emitter;

import compiler.frontend.scanner;

import compiler.ir.ir_constant;
import compiler.ir.ir_builder;
import compiler.ir.ir_label;

import std.conv;
import std.stdio;

struct Emitter
{
    Scanner scanner = Scanner("1 2 3 4 5 ++++.\0");

    IR_Builder builder;
    IR_Label *current_label;
    
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

    void push(IR_Constant constant)
    {
        ++stack_count;
        current_label.assign(current_label.add_register(), constant);
    }

    IR_Constant pop()
    {
        if (stack_count == 0)
            writeln("tried to pop nothing.");

        return IR_Constant(current_label.register_index - (stack_count--));
    }

    void emit()
    {
        advance();

        switch (scanner.previous.kind)
        {
            case TokenKind.Integer:
            {
                push(IR_Constant(to!(long)(scanner.previous.content)));
                break;
            }

            case TokenKind.Float:
            {
                push(IR_Constant(to!(double)(scanner.previous.content)));
                break;
            }

            case TokenKind.Plus:
            {
                IR_Constant a = pop();
                IR_Constant b = pop();

                ++stack_count;
                current_label.add(current_label.add_register(), a, b);
                break;
            }

            case TokenKind.Dot:
            {
                current_label.cout(pop());
                break;
            }

            default:
                break;
        }
    }

    void start()
    {
        writeln("-- INPUT --\n", scanner.source, '\n');
        current_label = builder.add_label("main");
        advance();

        while (!match(TokenKind.End))
            emit();
    }
}