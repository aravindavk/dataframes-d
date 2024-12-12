module dataframes.rows;

import std.traits;
import std.conv : text;
import std.range;
import std.format;
import std.variant;
import core.exception;
import std.datetime;
import std.json;

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

    /**
     * Access the column by label
     */
    Variant opIndex(string label)
    {
        Variant output;
    s1: switch (label)
        {
            static foreach(name; fieldNames)
            {
                mixin("case \"" ~ name ~ "\": output = this.df." ~ name ~ "[this.index]; break s1;");
            }
        default:
            throw new RangeError("invalid label");
        }
        return output;
    }

    /**
       Access the column by index
     */
    Variant opIndex(size_t idx)
    {
        return opIndex(this.df.columnNames[idx]);
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

    JSONValue toJSON()
    {
        JSONValue rowdata;
        static foreach(name; fieldNames)
            mixin("rowdata[name] = this." ~ name ~ ";");

        return rowdata;
    }
}

DataFrame!T toDataFrame(T, Range)(Range rows)
{
    auto df = new DataFrame!T;

    foreach(row; rows)
        df.add(row.toDataFrameStruct!T);

    return df;
}
