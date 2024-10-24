module dataframe;

import std.traits;

import dataframe.columns;
import dataframe.rows;


/**
 * DataFrame
 */
struct DataFrame(T)
{
    alias fieldNames = FieldNameTuple!(T);
    alias fieldTypes = FieldTypeTuple!(T);

    static foreach(idx, type; fieldTypes)
    {
        mixin(Column!(type).stringof ~ " " ~ fieldNames[idx] ~ ";");
    }

    /**
     * Get the list of column names
     */
    string[] columnNames()
    {
        string[] names;
        foreach(name; fieldNames)
            names ~= name;

        return names;
    }

    /**
     * Get the number of columns
     */
    size_t ncol()
    {
        return fieldNames.length;
    }

    /**
     * Get the number of rows
     */
    size_t length()
    {
        return  __traits(getMember, this, fieldNames[0]).length;
    }

    /**
     * Get the number of rows. Alias of `length`
     */
    size_t nrow()
    {
        return length;
    }

    /**
     * Add a row to the dataframe.
     */
    void add(T data)
    {
        // Expands to this.fieldName ~= data.fieldName;
        static foreach(name; fieldNames)
            mixin("this." ~ name ~ " ~= " ~ "data." ~ name ~ ";");
    }

    Row!T row(size_t idx)
    {
        return Row!T(this, idx);
    }
}

unittest
{
    struct Item
    {
        string name;
        double price;
        int quantity;
    }

    DataFrame!Item df;

    assert(df.ncol == 3);

    df.name = ["A", "B", "C", "D"];
    df.price = [149.0, 799.0, 399.0, 299.0];
    df.quantity = [3, 1, 2, 1];

    assert(df.nrow == 4);
    assert(df.length == 4);

    assert(df.columnNames == ["name", "price", "quantity"]);

    auto item = Item("E", 49.0, 10);
    df.add(item);
    assert(df.nrow == 5);

    auto row = Row!Item(df, 0);
    assert(row.name == "A");
    assert(row.price == 149.0);
    assert(row.quantity == 3);

    auto row2 = Row!Item(df, 3);
    assert(row2.name == "D");
    assert(row2.price == 299.0);
    assert(row2.quantity == 1);

    assert(df.row(0).name == "A");
}
