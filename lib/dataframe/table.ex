defmodule DataFrame.Table do
  @moduledoc """
    Table contains functions which act upon a 2D structure with data: a list of lists.
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

  @spec at([[number]], number, number) :: number
  def at(table, index, column) do
    table |> Enum.at(index) |> Enum.at(column)
  end

  def slice(table, range_index, range_column) do
    table |> Enum.slice(range_index) |> Enum.map(&Enum.slice(&1, range_column))
  end

  @spec dimensions([[number]]) :: [non_neg_integer]
  def dimensions(table) do
    row_count = Enum.count(table)
    column_count = Enum.count(Enum.at(table, 0))
    [row_count, column_count]
  end

  @spec map([[number]], function) :: [[number]]
  def map(table, func) do
    Enum.map(table, fn(column) -> Enum.map(column, fn(y) -> func.(y) end) end)
  end

  @spec add_column([[number]], [number]) :: [[number]]
  def add_column(table, column) do
    if Enum.count(column) != Enum.count(table) do
      raise ArgumentError, "column is not of the right dimmension"
    end
    column |> Enum.zip(table) |> Enum.map(&Tuple.to_list/1) |> Enum.map(&List.flatten/1)
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
