#ifndef BUILTIN_HPP
#define BUILTIN_HPP

#include <cstdio>
#include <runtime/constant.hpp>

// Write constant to console output
static inline void cout(const Constant &constant)
{
    switch (constant.kind)
    {
        // String
        case constant_string:
        {
            printf("%s", constant.as_string);
            break;
        }

        // Number
        case constant_number:
        {
            printf("%g", constant.as_number);
            break;
        }
    }
}

#endif