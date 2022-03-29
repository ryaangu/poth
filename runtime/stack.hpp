#ifndef STACK_HPP
#define STACK_HPP

#include <runtime/constant.hpp>

// A struct that represents a stack.
struct Stack
{
    // All the stack values
    Constant data[1024];

    // The stack top
    Constant *top;

    // Default Constructor
    Stack(void)
    {
        top = data;
    }

    // Push value
    inline void push(const Constant &value)
    {
        *top++ = value;
    }

    // Pop value
    inline Constant &pop(void)
    {
        return *(--top);
    }
};

#endif