
defmodule DataFrame do
  @moduledoc """
    Functions to create and modify a Frame, a structure with a 2D table with information, indexes and columns
  """
  alias DataFrame.Table
  alias DataFrame.Frame

  @doc """
    Creates a new Frame from a 2D table, It creates a numeric index and a numeric column array automatically.
  """
  def new(values) do
    index = autoindex_for_values_dimension(values, 0)
    columns = autoindex_for_values_dimension(values, 1)
    new(values, columns, index)
  end

  @doc """
    Creates a new Frame from a 2D table, and a column array. It creates a numeric index automatically.
  """
  def new(values, columns) when is_list(columns) do
    index = autoindex_for_values_dimension(values, 0)
    new(values, columns, index)
  end

  @doc """
    Creates a new Frame from a 2D table, an index and a column array
  """
  @spec new(Table.t | list, list, list) :: Frame.t
  def new(table, columns, index) when is_list(index) and is_list(columns) do
    values = Table.new(table)
    Table.check_dimensional_compatibility!(values, index, 0)
    Table.check_dimensional_compatibility!(values, columns, 1)
    %Frame{values: values, index: index, columns: columns}
  end

  defp autoindex_for_values_dimension(values, dimension) do
    table_dimension = values |> Table.new |> Table.dimensions |> Enum.at(dimension)
    if table_dimension == 0 do
      []
    else
      Enum.to_list 0..table_dimension - 1
    end
  end

  @doc """
    Creates a Frame from the textual output of a frame (allows copying data from webpages, etc.)
  """
  @spec parse(String.t) :: Frame.t
  def parse(text) do
    [header | data ] = String.split(text, "\n", trim: true)
    columns = String.split(header, " ", trim: true)
    data_values = data |> Table.new |> Table.map_rows(&(String.split(&1, " ", trim: true)))
    [values, index] = Table.remove_column(data_values, 0, return_column: true)
    values_data = Table.map(values, &transform_type/1)
    columns_data = Enum.map(columns, &transform_type/1)
    index_data = Enum.map(index, &transform_type/1)
    new(values_data, columns_data, index_data)
  end

  # TODO: Refactor, probably this is the most non-Elixir code even written
  defp transform_type(element) do
    int = Integer.parse(element)
    if int == :error or (elem(int, 1) != "") do
      float = Float.parse(element)
      if float == :error or (elem(float, 1) != "") do
        element
      else
        elem(float, 0)
      end
    else
      elem(int, 0)
    end
  end

  # ##################################################
  #  Transforming and Sorting
  # ##################################################

  @doc """
    Returns a Frame which data has been transposed.
  """
  @spec transpose(Frame.t) :: Frame.t
  def transpose(frame) do
    %Frame{values: Table.transpose(frame.values), index: frame.columns, columns: frame.index}
  end

  @doc """
  Creates a list of Dataframes grouped by one of the columns.
  A , B
  1 , 2
  1,  3
  2, 4
  group_by(A)
  [ A B
    1 2
    1 3,
    A B
    2 4
  ]
  """
  def group_by(frame, master_column) do
    frame
    |> column(master_column)
    |> Enum.uniq
    |> Enum.map(fn(value) -> filter_rows(frame, master_column, value) end)
  end

  @doc """
  DataFrame.to_list_of_maps DataFrame.new([[1,2],[3,4]], ["A", "B"])
  > [%{"A" => 1, "B" => 2}, %{"A" => 3, "B" => 4}]
  """
  def to_list_of_maps(_) do
    # TODO
  end

  @doc """
    Sorts the data in the frame based on its index. By default the data is sorted in ascending order.
  """
  @spec sort_index(Frame.t, boolean) :: Frame.t
  def sort_index(frame, ascending \\ true) do
    sort(frame, 0, ascending)
  end

  @doc """
    Sorts the data in the frame based on a given column. By default the data is sorted in ascending order.
  """
  @spec sort_values(Frame.t, String.t, boolean) :: Frame.t
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
      |> Table.append_column(frame.index)
      |> Table.sort_rows(fn(x,y) -> sorting_func.(x,y) end)
      |> Table.remove_column(0, return_column: true)

      DataFrame.new(values, frame.columns, index)
  end

  # ##################################################
  #  Selecting
  # ##################################################

  @doc """
  Returns the information at the top of the frame. Defaults to 5 lines.
  """
  @spec head(Frame.t, integer) :: Frame.t
  def head(frame, size \\ 5) do
    DataFrame.new(Enum.take(frame.values, size), frame.columns, Enum.take(frame.index, size))
  end

  @doc """
  Returns the information at the bottom of the frame. Defaults to 5 lines.
  """
  @spec tail(Frame.t, integer) :: Frame.t
  def tail(frame, the_size \\ 5) do
    size = -the_size
    head(frame, size)
  end

  @doc """
  Generic method to return rows based on the value of the index
  """
  def rows(frame, first..last) when is_integer(first) and is_integer(last) do
    irows(frame, indexes_by_named_range(frame.index, first..last))
  end
  def rows(frame, row_names) when is_list(row_names) do
    irows(frame, indexes_by_name(frame.index, row_names))
  end

  @doc """
  Generic method to return rows based on the position of the index
  """
  def irows(frame, first..last) when is_integer(first) and is_integer(last) do
    irows(frame, Enum.to_list(first..last))
  end
  def irows(frame, row_indexes) when is_list(row_indexes) do
    rows = multiple_at(frame.index, row_indexes)
    values = Table.rows(frame.values, row_indexes)
    DataFrame.new(values, frame.columns, rows)
  end

  @doc """
  Returns a Frame with the selected columns by name.
  """
  def columns(frame, first..last) when is_integer(first) and is_integer(last) do
    icolumns(frame, indexes_by_named_range(frame.columns, first..last))
  end
  def columns(frame, column_names) when is_list(column_names) do
    icolumns(frame, indexes_by_name(frame.columns, column_names))
  end

  @doc """
  Returns a Frame with the selected columns by position.
  """
  def icolumns(frame, first..last) when is_integer(first) and is_integer(last) do
    icolumns(frame, Enum.to_list(first..last))
  end
  def icolumns(frame, column_indexes) when is_list(column_indexes) do
    columns = multiple_at(frame.columns, column_indexes)
    values = Table.columns(frame.values, column_indexes)
    DataFrame.new(values, columns, frame.index)
  end

  @doc """
    Returns the data in the frame.
    Parameters are any list of rows and columns with names or a ranges of names
    To get only rows or columns check the functions above
  """
  @spec loc(Frame.t, Range.t | list(), Range.t | list()) :: Frame.t
  def loc(frame, row_names, column_names) do
    frame |> rows(row_names) |> columns(column_names)
  end

  @doc """
    Returns a slice of the data in the frame.
    Parameters are any list of rows and columns
  """
  @spec iloc(Frame.t, Range.t | list(integer), Range.t | list(integer)) :: Frame.t
  def iloc(frame, row_index, column_index) do
    frame |> irows(row_index) |> icolumns(column_index)
  end

  # TODO: move somewhere
  # same than .at but accepting a list of indexes
  defp multiple_at(list, list_index) do
    list_index
    |> Enum.map(fn(index) -> Enum.at(list, index) end)
    |> Enum.filter(fn(element) -> element != nil end)
  end

  defp indexes_by_named_range(list, first..last) do
    first_index = Enum.find_index(list, fn(x) -> to_string(x) == to_string(Enum.at(first, 0)) end)
    last_index  = Enum.find_index(list, fn(x) -> to_string(x) == to_string(Enum.at(last, 0)) end)
    Enum.to_list(first_index..last_index)
  end

  defp indexes_by_name(name_list, selected_names) when is_list(selected_names) do
    indexes = name_list |> Enum.with_index |> Enum.reduce([], fn(tuple, acc) ->
      if Enum.member?(selected_names, elem(tuple,0)) do
        [elem(tuple, 1) | acc]
      else
        acc
      end
    end)
    Enum.reverse(indexes)
  end

  @doc """
    Returns a value located at the position indicated by an index name and column name.
  """
  @spec at(Frame.t, String.t, String.t) :: any()
  def at(frame, index_name, column_name) do
    index = Enum.find_index(frame.index, fn(x) -> to_string(x) == to_string(index_name) end)
    column = Enum.find_index(frame.columns, fn(x) -> to_string(x) == to_string(column_name) end)
    DataFrame.iat(frame, column, index)
  end

  @doc """
    Returns a value located at the position indicated by an index position and column position.
  """
  @spec iat(Frame.t, integer, integer) :: any()
  def iat(frame, index, column) do
    Table.at(frame.values, index, column)
  end

  @doc """
  Returns a list of data, not a frame like object. with the values of a given column
  """
  @spec column(Frame.t, String.t) :: list()
  def column(frame, column_name) do
    column = Enum.find_index(frame.columns, fn(x) -> to_string(x) == to_string(column_name) end)
    frame.values |> Table.columns([column]) |> Table.to_row_list |> List.flatten
  end

  @doc """
    Experimental
    Returns the rows that contains certain value in a column
    # TODO: rationalize all this slicing operations
  """
  def filter_rows(frame, expected_column_name, expected_value) do
    column_index = Enum.find_index(frame.columns, fn(x) -> x == expected_column_name end)
    if column_index == nil do
      frame
    else
      values = Table.map_rows(frame.values,
       fn(row) ->
         if Enum.at(row, column_index) == expected_value do
           row
         else
           [nil]
         end
       end
     )
     {new_values, new_index} = delete_nil_rows(values, frame.index)
     DataFrame.new(new_values, frame.columns, new_index)
    end

  end

  @doc """
  Experimental
  Returns a frame with the info for which `fun` returned true. Extremely greedy. Only elements, not rows/columns
  """
  def filter(frame, fun) do
    with_nils = Enum.map(Table.with_index(frame.values), fn(row_tuple) ->
      row = elem(row_tuple, 0)
      row_index = elem(row_tuple, 1)
      row_name = Enum.at(frame.index, row_index)
      Enum.map row, fn(column_tuple) ->
        value = elem(column_tuple, 0)
        column_index = elem(column_tuple, 1)
        column_name = Enum.at(frame.columns, column_index)
        if fun.(value, column_name, column_index, row_name, row_index) do
          value
        else
          nil
        end
      end
    end)
    {new_table, new_index} = delete_nil_rows(with_nils, frame.index)
    #  new_columns = frame.columns
    {final_table, new_columns} = delete_nil_rows(Table.transpose(new_table), frame.columns)
    result_table = if final_table == [[]] do
        [[]]
      else
         Table.transpose(final_table)
        end
    DataFrame.new(result_table, new_columns, new_index)
  end

  defp delete_nil_rows([], _) do
    {Table.new, []}
  end
  defp delete_nil_rows(table, list) do
    nil_index = Enum.find_index(table, fn(row) -> Enum.all?(row, fn(element) -> element == nil end) end)
    if nil_index == nil do
      {table, list}
    else
      delete_nil_rows(List.delete_at(table, nil_index), List.delete_at(list, nil_index))
    end
  end

  # ##################################################
  #  Mathematics
  # ##################################################

  @doc """
    Returns the cummulative sum
  """
  @spec cumsum(Frame.t) :: Frame.t
  def cumsum(frame) do
    cumsummed = frame.values |> Table.map_columns( fn(column) ->
      Enum.flat_map_reduce(column, 0, fn(x, acc) ->
        {[x + acc], acc + x}
      end)
    end)
    data = Enum.at cumsummed, 0
    DataFrame.new(Table.transpose(data), frame.columns)
  end

  @doc """
    Returns a statistical description of the data in the frame
  """
  @spec describe(Frame.t) :: Frame.t
  def describe(frame) do
    DataFrame.Statistics.describe(frame)
  end

  # ##################################################
  #  Importing, exporting, plotting
  # ##################################################

  @doc """
    Writes the information of the frame into a csv file. By default the column names are written also
  """
  def to_csv(frame, filename, header \\ true) do
    file = File.open!(filename, [:write])
    values = if header do
      [frame.columns | frame.values]
    else
      frame.values
    end
    values |> CSV.encode |> Enum.each(&IO.write(file, &1))
  end

  @doc """
    Reads the information from a CSV file. By default the first row is assumed to be the column names.
  """
  @spec from_csv(String.t) :: Frame.t
  def from_csv(filename) do
    [headers | values] = filename |> File.stream! |> CSV.decode |> Enum.to_list
    new(values, headers)
  end

  @spec plot(Frame.t) :: :ok
  def plot(frame) do
    plotter = Explot.new
    columns_with_index = frame.values |> Table.transpose |> Enum.with_index
    Enum.each columns_with_index, fn(column_with_index) ->
      column = elem(column_with_index, 0)
      column_name = Enum.at(frame.columns, elem(column_with_index, 1))
      Explot.add_list(plotter, column, column_name)
    end
    Explot.x_axis_labels(plotter, frame.index)
    Explot.show(plotter)
  end
end
#DataFrame.new(DataFrame.Table.build_random(6,4), [1,3,4,5], DataFrame.DateRange.new("2016-09-12", 6) )
