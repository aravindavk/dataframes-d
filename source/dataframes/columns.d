module dataframes.columns;

import std.traits;
import std.array;

import dataframes.helpers;

/**
 * DataFrame Column to store all the elements of
 * the column.
 */
struct Column(T)
{
    T[] data;

    /**
     * Get the length of Items in the column
     */
    size_t length()
    {
        return data.length;
    }

    /**
     * Assign the Column data at once.
     */
    void opAssign(T[] rhs)
    {
        // Length is set by the dataframe so insert data
        if (data.length != rhs.length)
            throw new DataFrameException("All arrays must be of the same length");

        data = rhs;
    }

    void opAssign(Column!T rhs)
    {
        // Length is set by the dataframe so insert data
        if (data.length != rhs.length)
            throw new DataFrameException("All arrays must be of the same length");

        data = rhs.data;
    }

    void opOpAssign(string op : "~")(T rhs)
    {
        data ~= rhs;
    }

    T opIndex(size_t idx)
    {
        return data[idx];
    }

    // TODO: Support all Operations?
    // +	-	*	/	%	^^	&
    // |	^	<<	>>	>>>	~	in
    static if (isNumeric!T)
    {
        auto opBinary(string op, T2)(T2 rhs)
        {
            alias OutputType = CommonType!(T, typeof(rhs.data[0]));
            Column!OutputType output;
            foreach(idx, d; data)
            {
                switch(op)
                {
                case "+":
                    output.data ~= d + rhs.data[idx];
                    break;
                case "/":
                    output.data ~= d / rhs.data[idx];
                    break;
                case "-":
                    output.data ~= d - rhs.data[idx];
                    break;
                case "*":
                    output.data ~= d * rhs.data[idx];
                    break;
                default:
                    assert(0, "Operator " ~ op ~ " not implemented");
                }
            }
            return output;
        }
    }

    T front()
    {
        return this.data.front;
    }

    void popFront()
    {
        this.data.popFront;
    }

    bool empty()
    {
        return this.data.empty;
    }

    T back()
    {
        return this.data.back;
    }

    void popBack()
    {
        return this.data.popBack;
    }
}

unittest
{
    auto data = Column!double([100.0, 200.0, 300.0]);
    assert(data.length == 3);

    auto c1 = Column!int([10, 20]);
    auto c2 = Column!int([10, 20]);
    assert(c1 + c2 == Column!int([20, 40]));

    auto price = Column!double([25, 30]);
    auto quantity = Column!int([10, 5]);
    auto unitPrice = price / quantity;

    assert(unitPrice == Column!double([2.5, 6]));
}
