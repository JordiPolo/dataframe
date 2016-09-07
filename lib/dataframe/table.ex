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

  @spec build_random(non_neg_integer, non_neg_integer) :: [[number]]
  def build_random(row_count, column_count) do
    function = fn(_, _) -> :rand.uniform end
    build(row_count, column_count, function)
  end

  @spec build(non_neg_integer, non_neg_integer, function) :: [[number]]
  def build(row_count, column_count, function) do
    Enum.map(1..row_count, fn (row) -> Enum.map(1..column_count, fn(column) -> function.(row, column) end) end)
  end

  def new(list_of_list) do
    list_of_list
  end

  def new(list_of_lists, from_columns: true) do
    transpose(list_of_lists)
  end

  # Converts a list of columns to a list of rows which is our internal structure
  # [[1,3,5], [2,4,6]]  ->  [[1,2], [3,4], [5,6]]
  def build_from_columns(list_of_columns) do
    transpose(list_of_columns)
  end

  @spec at([[number]], number, number) :: number
  def at(table, index, column) do
    table |> Enum.at(index) |> Enum.at(column)
  end

  def slice(table, range_index, range_column) do
    table |> Enum.slice(range_index) |> Enum.map(&Enum.slice(&1, range_column))
  end

  def x_dimension(table) do
    dimensions(table) |> Enum.at(1)
  end

  def y_dimension(table) do
    dimensions(table) |> Enum.at(0)
  end

  @spec dimensions([[number]]) :: [non_neg_integer]
  def dimensions(table) do
    row_count = table |> Enum.filter(&(!Enum.empty?(&1))) |> Enum.count
    column_count = table |> Enum.at(0) |> Enum.count
    [row_count, column_count]
  end

  @spec map([[number]], function) :: [[number]]
  def map(table, func) do
    Enum.map(table, fn(column) -> Enum.map(column, fn(y) -> func.(y) end) end)
  end

  @spec append_column([[number]], [number]) :: [[number]]
  def append_column(table, column) do
    check_dimensional_compatibility!(table, column, 0)
    column |> Enum.zip(table) |> Enum.map(&Tuple.to_list/1) |> Enum.map(&List.flatten/1)
  end

  def remove_column(table, column_index, return_column: true) do
    column = List.flatten columns(table, column_index..column_index)
    rest = columns(table, 1..-1)
    [rest, column]
  end

  def check_dimensional_compatibility!(table, list, dimension) do
    list_dimension = Enum.count(list)
    table_dimension = table |> dimensions |> Enum.at(dimension)
    if list_dimension != table_dimension do
      raise ArgumentError,
        "Table dimension #{table_dimension} does not match the #{dimension_name(dimension)} dimension #{list_dimension}"
    end
  end

  defp dimension_name(dimension) when dimension == 1 do
    "row"
  end

  defp dimension_name(dimension) when dimension == 0 do
    "column"
  end


  def columns(table, range) do
    Enum.map(table, fn(x) -> Enum.slice(x, range) end)
  end

  @spec transpose([[number]]) :: [[number]]
  def transpose([[]|_]), do: []

  def transpose(table) do
    [Enum.map(table, &hd/1) | transpose(Enum.map(table, &tl/1))]
  end
end


#DataFrame.new(Table.build_random(6,4), DateRange.new("2016-09-12", 6), [1,3,4,5])
