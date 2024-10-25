module dataframe.columns;

import dataframe.helpers;

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

    void opOpAssign(string op : "~")(T rhs)
    {
        data ~= rhs;
    }

    T opIndex(size_t idx)
    {
        return data[idx];
    }
}

unittest
{
    auto data = Column!double([100.0, 200.0, 300.0]);
    assert(data.length == 3);
}
