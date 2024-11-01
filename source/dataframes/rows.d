module dataframes.rows;

import std.traits;
import std.conv : text;
import std.range;
import std.format;

import dataframes;

struct Row(T)
{
    DataFrame!T df;
    size_t index;

    alias fieldNames = FieldNameTuple!(T);
    alias fieldTypes = FieldTypeTuple!(T);

    static foreach(idx, name; fieldNames)
    {
        // For each DataFrame column, add a function to access the
        // row by name. For example,
        //     double price() { return this.df.price[this.rowIndex]; }
        mixin(i"$(fieldTypes[idx].stringof) $(name)() {return this.df.$(name)[this.index];}".text);
    }

    string toString()
    {
        auto output = appender!string;

        output ~= format("Row(index=%s", this.index);

        static foreach(name; fieldNames)
        {
            static if(isNumeric!(typeof( __traits(getMember, this.df, name).values[0])))
            {
                if (is(typeof( __traits(getMember, this.df, name).values[0]) == double))
                    output.put(format(", %.2f", __traits(getMember, this.df, name).values[index]));
                else
                    output.put(format(", %s", __traits(getMember, this.df, name).values[index]));
            }
            else
                output.put(format(", %s", __traits(getMember, this.df, name).values[index]));
        }

        return output.data ~ ")";
    }

    T1 toDataFrameStruct(T1)()
    {
        alias outputFieldNames = FieldNameTuple!(T1);
        T1 output;

        static foreach(name; outputFieldNames)
        {
            static if(hasMember!(T, name))
                __traits(getMember, output, name) = __traits(getMember, this, name);
        }

        return output;
    }
}

DataFrame!T to_df(T, Range)(Range rows)
{
    auto df = new DataFrame!T;

    foreach(row; rows)
        df.add(row.toDataFrameStruct!T);

    return df;
}
