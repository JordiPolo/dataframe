
defmodule DataFrame do
  @moduledoc """
    Functions to create and modify a Frame, a structure with a 2D table with information, indexes and columns
  """
  alias DataFrame.Table
  alias DataFrame.Frame

  @doc """
    Creates a new Dataframe from a 2D table, an index and a column array
  """
  def new(table, index, columns) do
    %Frame{values: table, index: index, columns: columns}
  end

  def new(table, columns) do
    index = Enum.to_list 0..Enum.count(table) - 1
    %Frame{values: table, index: index, columns: columns}
  end

  def head(frame, size \\ 5) do
    DataFrame.new(Enum.take(frame.values, size), Enum.take(frame.index, size), frame.columns)
  end

  def tail(frame, the_size \\ 5) do
    size = -the_size
    head(frame, size)
  end

  def describe(frame) do
    DataFrame.Statistics.describe(frame)
  end

  def transpose(frame) do
    %Frame{values: Table.transpose(frame.values), index: frame.columns, columns: frame.index}
  end

  def sort_index(frame, ascending \\ true) do
    sort(frame, 0, ascending)
  end

  def sort_values(frame, column_name, ascending \\ true) do
    index = Enum.find_index(frame.columns, fn(x) -> x == column_name end)
    sort(frame, index + 1, ascending)
  end

  defp sort(frame, column_index, ascending) do
    sorting_func = if ascending do
      fn(x,y) -> Enum.at(x, column_index) > Enum.at(y, column_index) end
    else
      fn(x,y) -> Enum.at(x, column_index) < Enum.at(y, column_index) end
    end
    frame.values
      |> Table.add_column(frame.index)
      |> Enum.sort(fn(x,y) -> sorting_func.(x,y) end)
      |> DataFrame.new(frame.columns)
  end

  def loc(frame, index_range, column_range) do
    # Assume the range is continuous in the data also.
    index = Enum.find_index(frame.index, fn(x) -> to_string(x) == to_string(Enum.at(index_range, 0)) end)
    column = Enum.find_index(frame.columns, fn(x) -> to_string(x) == to_string(Enum.at(column_range, 0)) end)
    index_range_integer = index..(index + Enum.count(index_range) - 1)
    column_range_integer = column..(column + Enum.count(column_range) - 1)
    DataFrame.iloc(frame, index_range_integer, column_range_integer)
  end

  def iloc(frame, index, columns) do
    new_index = frame.index |> Enum.slice(index)
    new_columns = frame.columns |> Enum.slice(columns)
    values = frame.values |> Table.slice(index, columns)
    DataFrame.new(values, new_index, new_columns)
  end

  def at(frame, index_name, column_name) do
    index = Enum.find_index(frame.index, fn(x) -> to_string(x) == to_string(index_name) end)
    column = Enum.find_index(frame.columns, fn(x) -> to_string(x) == to_string(column_name) end)
    DataFrame.iat(frame, index, column)
  end

  def iat(frame, index, column) do
    Table.at(frame.values, index, column)
  end

  def to_csv(frame, filename, header \\ true) do
    file = File.open!(filename, [:write])
    values = if (header) do
      [frame.columns | frame.values]
    else
      frame.values
    end
    values |> CSV.encode |> Enum.each(&IO.write(file, &1))
  end

  def from_csv(filename) do
    [headers | values] = filename |> File.stream! |> CSV.decode |> Enum.to_list
    new(values, headers)
  end

end
#DataFrame.new(Table.build_random(6,4), DateRange.new("2016-09-12", 6), [1,3,4,5])
