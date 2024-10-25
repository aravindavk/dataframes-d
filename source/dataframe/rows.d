module dataframe.rows;

import std.traits;
import std.conv : text;

import dataframe;

struct Row(T)
{
    DataFrame!T df;
    size_t rowIndex;

    alias fieldNames = FieldNameTuple!(T);
    alias fieldTypes = FieldTypeTuple!(T);

    this(DataFrame!T df, size_t rowIndex)
    {
        this.df = df;
        this.rowIndex = rowIndex;
    }

    static foreach(idx, name; fieldNames)
    {
        // For each DataFrame column, add a function to access the
        // row by name. For example,
        //     double price() { return this.df.price[this.rowIndex]; }
        mixin(i"$(fieldTypes[idx].stringof) $(name)() {return this.df.$(name)[this.rowIndex];}".text);
    }
}
