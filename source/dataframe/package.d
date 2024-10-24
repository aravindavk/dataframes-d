module dataframe;

import std.traits;

struct DataFrame(T)
{
    alias fieldNames = FieldNameTuple!(T);
    alias fieldTypes = FieldTypeTuple!(T);

    size_t ncol()
    {
        return fieldNames.length;
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
}
