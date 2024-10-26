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
            static if(isNumeric!(typeof( __traits(getMember, this.df, name).data[0])))
            {
                if (is(typeof( __traits(getMember, this.df, name).data[0]) == double))
                    output.put(format(", %.2f", __traits(getMember, this.df, name).data[index]));
                else
                    output.put(format(", %s", __traits(getMember, this.df, name).data[index]));
            }
            else
                output.put(format(", %s", __traits(getMember, this.df, name).data[index]));
        }

        return output.data ~ ")";
    }
}
