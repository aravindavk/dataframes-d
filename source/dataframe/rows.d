module dataframe.rows;

import std.traits;
import std.conv : text;
import std.range;

import dataframe;

struct Rows(T)
{
    DataFrame!T df;
    size_t[] indices;

    alias fieldNames = FieldNameTuple!(T);
    alias fieldTypes = FieldTypeTuple!(T);

    this(DataFrame!T df, size_t[] indices)
    {
        this.df = df;
        this.indices = indices;
    }

    Rows!T save()
    {
        return this;
    }

    bool empty()
    {
        return this.indices.empty;
    }

    Row!T front()
    {
        return Row!T(this.df, this.indices.front);
    }

    void popFront()
    {
        this.indices.popFront;
    }

    Row!T back()
    {
        return Row!T(this.df, this.indices.back);
    }

    void popBack()
    {
        this.indices.popBack;
    }
}

struct Row(T)
{
    DataFrame!T df;
    size_t index;

    alias fieldNames = FieldNameTuple!(T);
    alias fieldTypes = FieldTypeTuple!(T);

    this(DataFrame!T df, size_t rowIndex)
    {
        this.df = df;
        this.index = rowIndex;
    }

    static foreach(idx, name; fieldNames)
    {
        // For each DataFrame column, add a function to access the
        // row by name. For example,
        //     double price() { return this.df.price[this.rowIndex]; }
        mixin(i"$(fieldTypes[idx].stringof) $(name)() {return this.df.$(name)[this.index];}".text);
    }
}
