# DataFrame

Simple DataFrame for D programming language. Each field from the given struct will be converted as DataFrame Column to store the array. This library is focused on making a easy to use DataFrame in D.

## Install

Add `dataframes` to your project by running the following command.

```
dub add dataframes
```

## Create a new DataFrame

Create a struct that represents the Row of the DataFrame. For example, to store the item and price information.

```d
struct Item
{
    string name;
    double unitPrice;
    int quantity;
}
```

With this library, we can't add more columns to DataFrame in runtime. So include the additional fields to the above struct if required. Example,

```d
struct Item
{
    string name;
    double unitPrice;
    int quantity;
    double totalPrice;
}
```

Now create the DataFrame.

```d
auto df = new DataFrame!Item;
```

## Adding items

To add initial data, initialize the DataFrame as,

```d
auto df = new DataFrame!Item(
    name: ["Pencil", "Pen", "Notebook"],
    unitPrice: [5.0, 10.0, 25.0],
    quantity: [5, 2, 7]
);
```

To add items one by one,

```d
df.add(Item("Pen", 10.0, 1));

// OR from the list of Items
foreach(item; items)
    df.add(item)
```

## Preview the DataFrame data

Print the DataFrame to see the content. If the DataFrame has less than or equal to 10 rows then it prints the full DataFrame. It prints only first 5 and the last 5 rows otherwise.

Example:

```d
df.writeln;
```

Sample output:

```
name         unitPrice    quantity  totalPrice
Pencil            5.00           5         nan
Pen              10.00           2         nan
Notebook         25.00           7         nan

3 rows
```

## Full Example

```
import std.stdio;

import dataframes;

struct Item
{
    string name;
    double unitPrice;
    int quantity;
    double totalPrice;
}

void main()
{
    auto df = new DataFrame!Item(
        name: ["Pencil", "Pen", "Notebook"],
        unitPrice: [5.0, 10.0, 25.0],
        quantity: [5, 2, 7]
    );

    // Preview
    df.writeln;
}
```

## Number of Columns and Rows

```d
writeln("Columns: ", df.ncol);
writeln("Rows   : ", df.nrow); // OR `df.length`
```

## Column names

```d
writeln(df.columnNames);
```

## Access Rows and Columns

Access rows by index.

```d
auto firstRow = df.row(0);
writeln(firstRow.name, " ", firstRow.unitPrice * firstRow.quantity);
```

Access column,

```d
auto firstPrice = df.unitPrice[0];
```

```d
auto names = df.name;
// OR
auto names = df["name"].get!string;
// OR
auto names = df[0].get!string;
```

To access column from a Row,

```d
auto firstRow = df.row(0);
string name = firstRow.name;
// OR
string name = firstRow["name"].get!string;
// OR
string name = firstRow[0].get!string;
```

## Updating the derived columns

In the above example, `totalPrice` data is not available in the initial dataset. To calculate the `totalPrice`,

```d
df.totalPrice = df.unitPrice * df.quantity;
```

Above command will update `totalPrice` of all the rows.

For complex formula or business logic, use the temporary column to calculate the total price and add the results to DataFrame.

```d
Column!double discounts;
foreach(name; df.name)
{
    if (name == "Notebook")
        discounts ~= 0.05;
    else if (name == "Pen")
        discounts ~= 0.02;
    else
        discounts ~= 0;
}

df.totalPrice = (df.unitPrice - discounts) * df.quantity;
```

Or multiply the column by a single number.

```d
df.totalPrice = (df.unitPrice - df.unitPrice * 0.05) * df.quantity;
```

## Head and Tail

To get first `n` records from the dataframe,

```d
auto firstTwo = df.head(2);
```

To get last `n` records from the DataFrame,

```d
auto lastValue = df.tail(1);
```

## Using `std.algorithm` goodies with the DataFrame

Following example shows the sum of total prices of a few selected items.

```d
df.rows
  .filter!(item => item.name == "Pencil" || item.name == "Pen")
  .map!(item => item.totalPrice)
  .sum
  .writeln;
```

Multisort using name and quantity fields.

```d
df.rows
    .multiSort!("a.name < b.name", "a.quantity > b.quantity")
    .writeln;
```

## Importing data from CSV file

If struct fields and data in CSV matches then we can give `csvReader!Item` to import all the items. But the CSV file may contain more data which are not imported. In such cases, define a new Tuple type.

```d
import std.csv;
import std.typecons;

//                         name    unitPrice  quantity
alias ItemCsvData = Tuple!(string, double,    int);
auto df = new DataFrame!Item;

auto file = File("items_2024_10_26.csv", "r");
// header: null to ignore the header row
foreach (record;file.byLine.joiner("\n").csvReader!ItemCsvData(header: null))
    df.add(Item(record[0], record[1], record[2]));

// Preview the imported data
df.writeln;
```

## Copying the DataFrame or creating DataFrame of new Type

To create a `PriceList` dataframe from the list of items.

```d
struct PriceList
{
    string name;
    double price;
}

df.rows
    .sort!("a.name < b.name")
    .uniq!("a.name == b.name")
    .to_df!PriceList
    .writeln;
```
