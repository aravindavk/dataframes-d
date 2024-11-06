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
    T[] values;

    /**
     * Get the length of Items in the column
     */
    size_t length()
    {
        return values.length;
    }

    /**
     * Assign the Column data at once.
     */
    void opAssign(T[] rhs)
    {
        // Length is set by the dataframe so insert data
        if (values.length != rhs.length)
            throw new DataFrameException("All arrays must be of the same length");

        values = rhs;
    }

    void opAssign(Column!T rhs)
    {
        // Length is set by the dataframe so insert data
        if (values.length != rhs.length)
            throw new DataFrameException("All arrays must be of the same length");

        values = rhs.values;
    }

    void opOpAssign(string op : "~")(T rhs)
    {
        values ~= rhs;
    }

    T opIndex(size_t idx)
    {
        return values[idx];
    }

    // TODO: Support all Operations?
    // +	-	*	/	%	^^	&
    // |	^	<<	>>	>>>	~	in
    static if (isNumeric!T)
    {
        auto opBinary(string op, T2)(T2 rhs)
        {
            static if (isNumeric!T2)
                alias OutputType = CommonType!(T, T2);
            else
                alias OutputType = CommonType!(T, typeof(rhs.values[0]));

            Column!OutputType output;
            foreach(idx, d; values)
            {
                static if (isNumeric!T2)
                    auto rhsValue = rhs;
                else
                    auto rhsValue = rhs.values[idx];

                switch(op)
                {
                case "+":
                    output.values ~= d + rhsValue;
                    break;
                case "/":
                    output.values ~= d / rhsValue;
                    break;
                case "-":
                    output.values ~= d - rhsValue;
                    break;
                case "*":
                    output.values ~= d * rhsValue;
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
        return this.values.front;
    }

    void popFront()
    {
        this.values.popFront;
    }

    bool empty()
    {
        return this.values.empty;
    }

    T back()
    {
        return this.values.back;
    }

    void popBack()
    {
        return this.values.popBack;
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
