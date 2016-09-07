# Lesson 1

Most of this tutorial has been stolen from [pandas lesson 1](http://nbviewer.jupyter.org/urls/bitbucket.org/hrojas/learn-pandas/raw/master/lessons/01%20-%20Lesson.ipynb).

In this tutorial we will assume you have included DataFrame in your project.


## Create data

The data set will consist of 5 baby names and the number of births recorded for that year (1880).

```elixir
# The inital set of baby names and bith rates
names = ["Bob","Jessica","Mary","John","Mel"]
births = [968, 155, 77, 578, 973]
```

First we create a 2D data structure with these two columns:
```elixir
values = DataFrame.Table.new([names, births], from_columns: true)
```

We are basically done creating the data set. We now will use the library to export this data set into a csv file.

frame will be a DataFrame data structure.
You can think of this structure holding the contents of the BabyDataSet in a format similar to an excel spreadsheet.
Lets take a look below at the contents inside frame.
```elixir
frame = DataFrame.new(values, ["Names", "Births"])
```

Output:
```
             Names         Births
0             bob           968
1             Jessica       155
2             Mary          77
3             John          578
4             Mel           973
```

## Exporting and importing data

Export the dataframe to a csv file. We can name the file births1880.csv.
The function to_csv will be used to export the file. The file will be saved in the same location of the project unless specified otherwise.

```elixir
DataFrame.to_csv(frame, "births1880.csv")
```

To import the data we can use the `from_csv` function.
```elixir
frame_from_file = DataFrame.from_csv("births1880.csv")
```
```
              Names         Births
0             bob           968
1             Jessica       155
2             Mary          77
3             John          578
4             Mel           973
```

As we can see the default is to both write and read the name of the columns and use automatic indexing.
Check the documentation of these functions to see other options.

## Analyze data

To find the most popular name or the baby name with the highest birth rate, we can sort the dataframe and select the top row:

```elixir
 frame_from_file |> DataFrame.sort_values("Births") |> DataFrame.head(1)
```

Will give us:
```
              Names         Births
4             Mel           973
```
