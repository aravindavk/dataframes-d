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
    int shiftBy;
    size_t currentFrontIndex = 0;
    size_t currentBackIndex;

    this(T[] values)
    {
        this.values = values;
        currentBackIndex = values.length;
    }

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

    size_t opDollar(size_t pos)()
    {
        return values.length;
    }

    auto opSlice()(size_t start, size_t end)
    {
        return values[start .. end];
    }

    T opIndex(size_t idx)
    {
        auto newIdx = idx - this.shiftBy;
        if (shiftBy != 0 && (newIdx < 0 || newIdx >= values.length)) return T.init;

        return values[newIdx];
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
                    auto rhsValue = rhs[idx];

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
        return this[currentFrontIndex];
    }

    void popFront()
    {
        currentFrontIndex++;
    }

    bool empty()
    {
        return currentFrontIndex >= this.values.length || currentBackIndex < 0;
    }

    T back()
    {
        return this[currentBackIndex];
    }

    void popBack()
    {
        currentBackIndex--;
    }

    Column!T shift(int value)
    {
        Column!T newCol;
        this.shiftBy = value;
        return this;
    }

    bool opEquals(Column!T rhs)
    {
        import std.math.operations : isClose;
        import std.range : enumerate;
        import std.math : isNaN;

        if (this.length != rhs.length) return false;

        foreach(idx, _value; this.values.enumerate)
        {
            static if (isFloatingPoint!T) {
                if ((this[idx].isNaN && !rhs[idx].isNaN) || (!this[idx].isNaN && rhs[idx].isNaN)) return false;
                else continue;
            }

            if (!isClose(this[idx], rhs[idx])) return false;
        }
        return true;
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

    auto c3 = Column!double([100, 200, 300]);
    auto c4 = Column!double([10, 20, 30]);

    assert(c3+c4.shift(1) == Column!double([double.init, 210, 320]));
    assert(c3+c4.shift(-1) == Column!double([120, 230, double.init]));

    import std.algorithm.iteration : sum, filter;
    import std.math : isNaN;

    assert(c3.shift(1).filter!(n => !n.isNaN).sum == 300);
    assert(c3.shift(-1).filter!(n => !n.isNaN).sum == 500);

    auto col1 = Column!int([10, 20, 30, 40, 50]);
    auto avgCol = (col1 + col1.shift(1)) / 2;
    assert(avgCol == Column!int([5, 15, 25, 35, 45]));
}
