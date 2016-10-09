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
  @opaque t :: nonempty_list(list(any))

  # ##################################################
  #  Creation
  # ##################################################

  @spec build_random(non_neg_integer, non_neg_integer) :: [[number]]
  def build_random(row_count, column_count) do
    function = fn(_, _) -> :rand.uniform end
    build(row_count, column_count, function)
  end

  @spec build(non_neg_integer, non_neg_integer, function) :: t
  def build(row_count, column_count, function) do
    rows = Enum.to_list 1..row_count
    columns = Enum.to_list 1..column_count
    Enum.map(rows, fn (row) -> Enum.map(columns, fn(column) -> function.(row, column) end) end)
  end

  def new([h | t]) when is_tuple(h) do
    list_of_lists = Enum.map [h | t], &Tuple.to_list/1
    new(list_of_lists)
  end

  @spec new(t | list) :: t
  def new(list_of_list) do
    list_of_list
  end

  # Converts a list of columns to a list of rows which is our internal structure
  # [[1,3,5], [2,4,6]]  ->  [[1,2], [3,4], [5,6]]
  def new(list_of_lists, from_columns: true) do
    transpose(list_of_lists)
  end

#  @spec new() :: t
  def new do
    [[]]
  end

  @spec to_row_list(t) :: list
  def to_row_list(table) do
    table
  end

  # ##################################################
  #  Information
  # ##################################################

  @spec dimensions(t) :: [non_neg_integer]
  def dimensions(table) do
    row_count = table |> Enum.filter(&(!Enum.empty?(&1))) |> Enum.count
    column_count = table |> Enum.at(0) |> Enum.count
    [row_count, column_count]
  end

  def x_dimension(table) do
    table |> dimensions |> Enum.at(1)
  end

  def y_dimension(table) do
    table |> dimensions |> Enum.at(0)
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

  @spec at(t, number, number) :: any
  def at(table, row, column) do
    table |> Enum.at(row) |> Enum.at(column)
  end

  @spec slice(t, Range.t, Range.t) :: t
  def slice(table, range_index, range_column) do
    table |> Enum.slice(range_index) |> Enum.map(&Enum.slice(&1, range_column))
  end

  @spec rows_columns(t, Range.t| list, Range.t | list) :: t
  def rows_columns(table, row_info, column_info) do
    table |> rows(row_info) |> columns(column_info)
  end

  @spec rows(t, list) :: t
  def rows(table, row_indexes) when is_list(row_indexes) do
    multiple_at(table, row_indexes)
  end

  @spec rows(t, Range.t) :: t
  def rows(table, first..last) when is_integer(first) and is_integer(last) do
    Enum.slice(table, first..last)
  end

  @spec columns(t, list) :: t
  def columns(table, column_indexes) when is_list(column_indexes) do
    Enum.map(table, fn(row) -> multiple_at(row, column_indexes) end)
  end

  @spec columns(t, Range.t) :: t
  def columns(table, first..last) when is_integer(first) and is_integer(last) do
    Enum.map(table, fn(x) -> Enum.slice(x, first..last) end)
  end

  # TODO: move somewhere
  # The implementation is not fast (map will transverse once and Enum.at again
  # but allows to return a list of list in the order given but list_index
  # so users of Table can reorder columns and/or rows
  defp multiple_at(list, list_index) do
    list_index
    |> Enum.map(fn(index) -> Enum.at(list, index) end)
    |> Enum.filter(fn(element) -> element != nil end)
  end

  # ##################################################
  #  Transversing
  # ##################################################

  @spec map_rows(t, function) :: t
  def map_rows(table, func) do
    Enum.map(table, &(func.(&1)))
  end

  @spec map_columns(t, function) :: t
  def map_columns(table, func) do
    table |> transpose |> map_rows(func) |> transpose
  end

  @spec map(t, function) :: t
  def map(table, func) do
    Enum.map(table, fn(column) -> Enum.map(column, fn(y) -> func.(y) end) end)
  end

  # Experimental
  def reduce(table, acc, fun) do
    table
    |> Enum.map(fn(row) -> Enum.reduce(row, acc, fun) end)
    |> Enum.reduce(acc, fun)
  end

  @spec with_index(t) :: nonempty_list({nonempty_list({any(), non_neg_integer()}), non_neg_integer()})
  def with_index(table) do
    table |> Enum.map(&Enum.with_index/1) |> Enum.with_index
  end

  # ##################################################
  #  Modyfing
  # ##################################################

  @spec append_column(t, [any]) :: t
  def append_column(table, column) do
    check_dimensional_compatibility!(table, column, 0)
    column |> Enum.zip(table) |> Enum.map(&Tuple.to_list/1) |> Enum.map(&List.flatten/1)
  end

  def remove_column(table, column_index, return_column: true) do
    column = List.flatten columns(table, column_index..column_index)
    rest = columns(table, 1..-1)
    [rest, column]
  end

  @spec transpose(t) :: t
  def transpose([[]]) do
    [[]]
  end

  def transpose(table) do
    table |> List.zip |> Enum.map(&Tuple.to_list(&1))
  end

  @spec sort_rows(t, function) :: t
  def sort_rows(table, sorting_func) do
    table |> Enum.sort(fn(x,y) -> sorting_func.(x,y) end)
  end
end
