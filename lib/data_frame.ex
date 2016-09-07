
defmodule DataFrame do
  @moduledoc """
    Functions to create and modify a Frame, a structure with a 2D table with information, indexes and columns
  """
  alias DataFrame.Table
  alias DataFrame.Frame

  @doc """
    Creates a new Frame from a 2D table, It creates a numeric index and a numeric column array automatically.
  """
  def new(table) when is_list(table) do
    index = autoindex_for_table_dimension(table, 0)
    columns = autoindex_for_table_dimension(table, 1)
    new(table, index, columns)
  end

  @doc """
    Creates a new Frame from a 2D table, and a column array. It creates a numeric index automatically.
  """
  def new(table, columns) when is_list(table) and is_list(columns) do
    index = autoindex_for_table_dimension(table, 0)
    new(table, index, columns)
  end

  @doc """
    Creates a new Frame from a 2D table, an index and a column array
  """
  def new(table, columns, index) when is_list(table) and is_list(index) and is_list(columns) do
    Table.check_dimensional_compatibility!(table, index, 0)
    Table.check_dimensional_compatibility!(table, columns, 1)
    %Frame{values: table, index: index, columns: columns}
  end

  defp autoindex_for_table_dimension(table, dimension) do
    table_dimension = table |> Table.dimensions |> Enum.at(dimension)
    if table_dimension == 0 do
      []
    else
      Enum.to_list 0..table_dimension - 1
    end
  end

  @doc """
    Returns the information at the top of the frame. Defaults to 5 lines.
  """
  def head(frame, size \\ 5) do
    DataFrame.new(Enum.take(frame.values, size), frame.columns, Enum.take(frame.index, size))
  end

  @doc """
    Returns the information at the bottom of the frame. Defaults to 5 lines.
  """
  def tail(frame, the_size \\ 5) do
    size = -the_size
    head(frame, size)
  end

  @doc """
    Returns a statistical description of the data in the frame
  """
  def describe(frame) do
    DataFrame.Statistics.describe(frame)
  end

  @doc """
    Returns a Frame which data has been transposed.
  """
  def transpose(frame) do
    %Frame{values: Table.transpose(frame.values), index: frame.columns, columns: frame.index}
  end

  @doc """
    Sorts the data in the frame based on its index. By default the data is sorted in ascending order.
  """
  def sort_index(frame, ascending \\ true) do
    sort(frame, 0, ascending)
  end

  @doc """
    Sorts the data in the frame based on a given column. By default the data is sorted in ascending order.
  """
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
    [values, index] = frame.values
      |> IO.inspect
      |> Table.append_column(frame.index)
      |> Enum.sort(fn(x,y) -> sorting_func.(x,y) end)
      |> Table.remove_column(0, return_column: true)

      DataFrame.new(values, frame.columns, index)
  end

  @doc """
    Returns a slice of the data in the frame.
    Parameters are the ranges with names in the index and column
  """
  def loc(frame, index_range, column_range) do
    # Assume the range is continuous in the data also.
    index = Enum.find_index(frame.index, fn(x) -> to_string(x) == to_string(Enum.at(index_range, 0)) end)
    column = Enum.find_index(frame.columns, fn(x) -> to_string(x) == to_string(Enum.at(column_range, 0)) end)
    index_range_integer = index..(index + Enum.count(index_range) - 1)
    column_range_integer = column..(column + Enum.count(column_range) - 1)
    DataFrame.iloc(frame, index_range_integer, column_range_integer)
  end

  @doc """
    Returns a slice of the data in the frame.
    Parameters are the ranges with positions in the index and column
  """
  def iloc(frame, index, columns) do
    new_index = frame.index |> Enum.slice(index)
    new_columns = frame.columns |> Enum.slice(columns)
    values = frame.values |> Table.slice(index, columns)
    DataFrame.new(values, new_columns, new_index)
  end

  @doc """
    Returns a value located at the position indicated by an index name and column name.
  """
  def at(frame, index_name, column_name) do
    index = Enum.find_index(frame.index, fn(x) -> to_string(x) == to_string(index_name) end)
    column = Enum.find_index(frame.columns, fn(x) -> to_string(x) == to_string(column_name) end)
    DataFrame.iat(frame, column, index)
  end

  @doc """
    Returns a value located at the position indicated by an index position and column position.
  """
  def iat(frame, index, column) do
    Table.at(frame.values, column, index)
  end

  @doc """
    Writes the information of the frame into a csv file. By default the column names are written also
  """
  def to_csv(frame, filename, header \\ true) do
    file = File.open!(filename, [:write])
    values = if (header) do
      [frame.columns | frame.values]
    else
      frame.values
    end
    values |> CSV.encode |> Enum.each(&IO.write(file, &1))
  end

  @doc """
    Reads the information from a CSV file. By default the first row is assumed to be the column names.
  """
  def from_csv(filename) do
    [headers | values] = filename |> File.stream! |> CSV.decode |> Enum.to_list
    new(values, headers)
  end

end
#DataFrame.new(Table.build_random(6,4), [1,3,4,5], DateRange.new("2016-09-12", 6) )
