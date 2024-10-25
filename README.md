# DataFrame

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

## Using `std.algorithm` goodies with the DataFrame

Following example shows the sum of total prices of a few selected items.

```d
df.rows
  .filter!(item => item.name == "Pencil" || item.name == "Pen")
  .map!(item => item.totalPrice)
  .sum
  .writeln;
```
