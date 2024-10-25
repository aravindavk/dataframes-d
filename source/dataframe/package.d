module dataframe;

import std.traits;
import std.range;
import std.algorithm;
import std.array;
import std.format;
import std.conv : text;

import dataframe.columns;
import dataframe.rows;
import dataframe.helpers;

/**
 * DataFrame
 */
class DataFrame(T)
{
    alias fieldNames = FieldNameTuple!(T);
    alias fieldTypes = FieldTypeTuple!(T);

    size_t[] index;

    static foreach(idx, type; fieldTypes)
    {
        mixin(Column!(type).stringof ~ " " ~ fieldNames[idx] ~ ";");
    }

    private static string initializerArgs()
    {
        import std.array;

        string[] args;
        static foreach(idx, type; fieldTypes)
        {
            // Ex: double[] price = []
            args ~= type.stringof ~ "[] " ~ fieldNames[idx] ~ " = []";
        }
        return args.join(", ");
    }

    private static string initializerContent()
    {
        string content;
        content ~= "size_t dfSize = 0;";
        content ~= "bool allColumnSameSize = true;";

        static foreach(idx, name; fieldNames)
        {
            // Ex: if (dfSize == 0) dfSize = FIELD.length
            content ~= "if (dfSize == 0) dfSize = " ~ name ~ ".length;";
            // Ex: if (dfSize != FIELD.length && FIELD.length > 0)
            //         allColumnSameSize = false;
            content ~= "if (dfSize != " ~ name ~ ".length && " ~ name ~ ".length > 0) allColumnSameSize = false;";
            // Ex: if (FIELD.length > 0)
            //         this.FIELD = FIELD;
            //     else
            //         this.FIELD.data.length = dfSize;
            content ~= "if (" ~ name ~ ".length > 0) this." ~ name ~ ".data = " ~ name ~ "; else this." ~ name ~ ".data.length = dfSize;";
        }

        content ~= "if (!allColumnSameSize) throw new DataFrameException(\"All arrays must be of the same length\");";
        content ~= "this.index = iota(length).array;";

        return content;
    }

    mixin("this(" ~ initializerArgs ~ "){" ~ initializerContent ~ "}");

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

        this.index ~= length - 1;
    }

    Row!T row(size_t idx)
    {
        return Row!T(this, idx);
    }

    Rows!T rows()
    {
        return Rows!T(this, iota(length).array);
    }

    private string formatRow(size_t idx)
    {
        auto output = appender!string;

        static foreach(name; fieldNames)
        {
            static if(isNumeric!(typeof( __traits(getMember, this, name).data[0])))
            {
                if (is(typeof( __traits(getMember, this, name).data[0]) == double))
                    output.put(format("%10.2f  ", __traits(getMember, this, name).data[idx]));
                else
                    output.put(format("%10s  ", __traits(getMember, this, name).data[idx]));
            }
            else
                output.put(format("%-10s  ", __traits(getMember, this, name).data[idx]));
        }

        return output.data ~ "\n";
    }

    private string formatHeader()
    {
        auto output = appender!string;

        if (length > 0)
        {
            foreach(cname; fieldNames)
            {
                static if(isNumeric!(typeof( __traits(getMember, this, cname).data[0])))
                    output.put(format("%10s  ", cname));
                else
                    output.put(format("%-10s  ", cname));
            }

            output ~= "\n";
        }

        return output.data;
    }

    override string toString()
    {
        auto output = appender!string;
        // TODO: Print Title and field information

        size_t previewSize = length > 10 ? 10 : length;

        output ~= formatHeader;

        if (length <= 10)
        {
            foreach(r; this.rows)
                output ~= formatRow(r.index);
        }
        else
        {
            rows.take(5).each!(r => output ~= formatRow(r.index));

            output.put(".\n.\n.\n");

            rows.tail(5).each!(r => output ~= formatRow(r.index));
        }

        output.put(i"\n$(length) rows".text);

        return output.data;
    }
}

unittest
{
    struct Item
    {
        string name;
        double price;
        int quantity;
        double totalPrice;
    }

    auto df = new DataFrame!Item(
        name: ["A", "B", "C", "D"],
        price: [149.0, 799.0, 399.0, 299.0],
        quantity: [3, 1, 2, 1]
        );

    assert(df.ncol == 4);
    assert(df.nrow == 4);
    assert(df.length == 4);

    assert(df.columnNames == ["name", "price", "quantity", "totalPrice"]);

    // Try to add column data of different length
    // than the other columns.
    import std.exception;
    assertThrown!DataFrameException(df.totalPrice = [10, 20]);

    // Values for this column not set during initialization,
    // but DataFrame should set the size as same as other columns
    assert(df.totalPrice.length == 4);

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

    df.totalPrice = df.price * df.quantity;
    assert(df.totalPrice == Column!double([447.0, 799.0, 798.0, 299.0, 490.0]));

    Column!double discounts;
    foreach(name; df.name)
    {
        if (name == "A")
            discounts ~= 0.05;
        else if (name == "C")
            discounts ~= 0.02;
        else
            discounts ~= 0;
    }

    df.totalPrice = (df.price - discounts) * df.quantity;
    // TODO: Fix approxEqual to fix the below test
    //assert(df.totalPrice == Column!double([446.85, 799, 797.96, 299, 490]));

    import std.algorithm;

    assert(df.rows
           .filter!(r => r.name == "A" || r.name == "B")
           .map!(r => r.quantity)
           .sum == 4);
}
