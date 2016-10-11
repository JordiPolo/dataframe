defmodule DataFrame.FrameMap do
  @moduledoc """
  Struct which defines a Frame, a 2D table with columns and rows information
  The fields are:
    * `values` - The values of the 2D table
    * `index` - The information of the rows
    * `columns` - The name of each column of the table
  """
  defstruct values: %{}, index: [], columns: []

  @type t :: %__MODULE__{
    values: map,
    index: list(any()),
    columns: list(any())
  }
end

defmodule DataFrameMap do
    alias DataFrame.FrameMap
    alias DataFrame.Table

  def new(values) do
    index = autoindex_for_values_dimension(values, 0)
    columns = autoindex_for_values_dimension(values, 1)
    new(values, columns, index)
  end

  def new(values, columns) when is_list(columns) do
    index = autoindex_for_values_dimension(values, 0)
    new(values, columns, index)
  end

  def new(values, columns, index) when is_list(index) and is_list(columns) do
    maps = for i <- index, j <-  columns, do:  {i, j}
    data = Enum.zip(maps, List.flatten(values))
    values = Enum.into(data, %{})
    %FrameMap{values: values, index: index, columns: columns}
  end

  defp autoindex_for_values_dimension(values, dimension) do
    table_dimension = values |> Table.new |> Table.dimensions |> Enum.at(dimension)
    if table_dimension == 0 do
      []
    else
      Enum.to_list 0..table_dimension - 1
    end
  end

  def transpose(frame) do
    old_keys = Map.keys(frame.values)
    old_values = Map.values(frame.values)
    transposed_keys = Enum.map old_keys, fn ({first, second}) -> {second, first} end
    frame_values = Enum.into(Enum.zip(transposed_keys, old_values), %{})

    %FrameMap{values: frame_values, index: frame.columns, columns: frame.index}
  end

  def rows(frame, first..last) when is_integer(first) and is_integer(last) do
    rows(frame, Enum.to_list(first..last))
  end

  def rows(frame, row_names) when is_list(row_names) do
    string_names = Enum.map(row_names, &to_string/1)
    filtered_values = Enum.filter frame.values, fn ({{first, second}, value}) ->
      to_string(first) in string_names
    end
    filtered_index = Enum.filter(frame.index, fn(element) -> to_string(element) in string_names end)
    %FrameMap{values: filtered_values, index: filtered_index, columns: frame.columns}
  end

  @spec head(Frame.t, integer) :: Frame.t
  def head(frame, size \\ 5) do
    index = Enum.take(frame.index, size)
    maps = Enum.zip(index, frame.columns)
    values = Map.take(frame.values, maps)
    %FrameMap{values: values, index: index, columns: frame.columns}
  end

  @doc """
  Returns the information at the bottom of the frame. Defaults to 5 lines.
  """
  @spec tail(Frame.t, integer) :: Frame.t
  def tail(frame, the_size \\ 5) do
    size = -the_size
    head(frame, size)
  end
end