#ifndef CONSTANT_HPP
#define CONSTANT_HPP

#include <cstdint>

// An enum that represents the kind of a Constant struct.
enum
{
    constant_null,
    constant_string,
    constant_number,
};

// A struct that represents a constant value.
struct Constant
{
    union
    {
        const char *as_string;
        double      as_number;
    };

    uint32_t kind;

    // Default Constructor
    Constant(void)
    {
        kind = constant_null;
    }

    // String Constant
    Constant(const char *value)
    {
        as_string = value;
        kind      = constant_string;
    }

    // Number Constant
    Constant(double value)
    {
        as_number = value;
        kind      = constant_number;
    }
};

#endif