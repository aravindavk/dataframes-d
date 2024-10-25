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
    double price;
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
    name: ["A", "B", "C"],
    price: [99.0, 299.0, 55.0],
    quantity: [2, 1, 4]
);
```

To add items one by one,

```d
df.add(Item("A", 99.0, 2));

// OR from the list of Items
foreach(item; items)
    df.add(item)
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
auto firstPrice = df.price[0];
```
