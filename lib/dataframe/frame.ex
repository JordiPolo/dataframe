
defmodule DataFrame.Frame do
  @moduledoc """
  Struct which defines a Frame, a 2D table with columns and rows information
  The fields are:
    * `values` - The values of the 2D table
    * `index` - The information of the rows
    * `columns` - The name of each column of the table
  """
  defstruct values: [[]], index: [], columns: []
end
