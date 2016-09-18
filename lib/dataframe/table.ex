defmodule DataFrame.Table do
  @moduledoc """
    Table contains functions which act upon a 2D structure with data: a list of lists.
    Internally this is implemented as a list of rows. Given a table:
    1 2
    3 4
    5 6
    Internally we are working with
    [[1,2], [3,4], [5,6]]
    dimensions would be:
    x_dimension = 2
    y_dimension = 3
  """

  @typedoc """
    A table is a list of lists, it can contain numbers strings atoms or be empty
  """
  @type table :: nonempty_list(list(any))

  # Experimental
  def reduce(t, acc, fun) do
    t.data
    |> Enum.map(fn(row) -> Enum.reduce(row, acc, fun) end)
    |> Enum.reduce(acc, fun)
  end
  # ##################################################
  #  Creation
  # ##################################################

  @spec build_random(non_neg_integer, non_neg_integer) :: [[number]]
  def build_random(row_count, column_count) do
    function = fn(_, _) -> :rand.uniform end
    build(row_count, column_count, function)
  end

  @spec build(non_neg_integer, non_neg_integer, function) :: table
  def build(row_count, column_count, function) do
    data = Enum.map(1..row_count, fn (row) -> Enum.map(1..column_count, fn(column) -> function.(row, column) end) end)
    # %DataFrame.NewTable{ data: data }
  end

  def new([h | t]) when is_tuple(h) do
    list_of_lists = Enum.map [h | t], &Tuple.to_list/1
    new(list_of_lists)
  end

  @spec new(table) :: table
  def new(list_of_list) do
    list_of_list
  end

  # Converts a list of columns to a list of rows which is our internal structure
  # [[1,3,5], [2,4,6]]  ->  [[1,2], [3,4], [5,6]]
  def new(list_of_lists, from_columns: true) do
    transpose(list_of_lists)
  end

  # ##################################################
  #  Information
  # ##################################################

  @spec dimensions(table) :: [non_neg_integer]
  def dimensions(table) do
    row_count = table |> Enum.filter(&(!Enum.empty?(&1))) |> Enum.count
    column_count = table |> Enum.at(0) |> Enum.count
    [row_count, column_count]
  end

  def check_dimensional_compatibility!(table, list, dimension) do
    list_dimension = Enum.count(list)
    table_dimension = table |> dimensions |> Enum.at(dimension)
    if list_dimension != table_dimension do
      raise ArgumentError,
        "Table dimension #{table_dimension} does not match the #{dimension_name(dimension)} dimension #{list_dimension}"
    end
  end

  @spec dimension_name(1) :: String.t
  defp dimension_name(dimension) when dimension == 1 do
    "row"
  end

  @spec dimension_name(0) :: String.t
  defp dimension_name(dimension) when dimension == 0 do
    "column"
  end


  # ##################################################
  #  Selecting
  # ##################################################

  @spec at(table, number, number) :: any
  def at(table, index, column) do
    table |> Enum.at(index) |> Enum.at(column)
  end

  @spec slice(table, Range.t, Range.t) :: table
  def slice(table, range_index, range_column) do
    table |> Enum.slice(range_index) |> Enum.map(&Enum.slice(&1, range_column))
  end

  def x_dimension(table) do
    dimensions(table) |> Enum.at(1)
  end

  def y_dimension(table) do
    dimensions(table) |> Enum.at(0)
  end

  # Real selecting of columns where we can have any column, substitute the columns method below
  def columns_index(table, columns) do
    Enum.map(table, fn(row) -> at_a(row, columns) end)
  end

  defp at_a(list, list_index) do
    Enum.map(list_index, fn(index) -> Enum.at(list, index) end)
  end

  def columns(table, range) do
    Enum.map(table, fn(x) -> Enum.slice(x, range) end)
  end

  # ##################################################
  #  Transversing
  # ##################################################

  @spec map(table, function) :: table
  def map(table, func) do
    Enum.map(table, fn(column) -> Enum.map(column, fn(y) -> func.(y) end) end)
  end

  @spec with_index(table) :: nonempty_list({nonempty_list({any(), non_neg_integer()}), non_neg_integer()})
  def with_index(table) do
    table |> Enum.map(&Enum.with_index/1) |> Enum.with_index
  end

  # ##################################################
  #  Modyfing
  # ##################################################

  @spec append_column(table, [any]) :: table
  def append_column(table, column) do
    check_dimensional_compatibility!(table, column, 0)
    column |> Enum.zip(table) |> Enum.map(&Tuple.to_list/1) |> Enum.map(&List.flatten/1)
  end

  def remove_column(table, column_index, return_column: true) do
    column = List.flatten columns(table, column_index..column_index)
    rest = columns(table, 1..-1)
    [rest, column]
  end

#  @spec transpose(table) :: table
  def transpose([[]|_]), do: []

  def transpose(table) do
    [Enum.map(table, &hd/1) | transpose(Enum.map(table, &tl/1))]
  end
end
