module dataframes.helpers;

import std.range.primitives : hasLength, hasSlicing;

class DataFrameException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

// Generic function for Rolling
// [10, 20, 30, 40].rolling!(mean, double)(2)
U[] rolling(alias func, U, T)(T data, int window)
    if (hasLength!T)
    {
        U[] output;
        if (data.length < window)
        {
            output.length = data.length;
            return output;
        }

        // Start filling after window. Fill with output
        // datatype default. Ex: nan for double
        output.length = window - 1;

        foreach(idx; 0..(data.length - window + 1))
            output ~= func(data[idx .. idx + window]);

        return output;
    }
