module dataframe;

import std.traits;

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
}
