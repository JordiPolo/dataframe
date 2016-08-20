require Timex
use Timex

defmodule DataFrame.DateRange do
  @moduledoc """
  Functions to manage Date ranges
  """


  @doc """
    Creates a list with dates starting at start_date, for periods number of days
    ## examples
        iex> DateRange.new("2016-09-12", 4)
        [~D[2016-09-12], ~D[2016-09-13], ~D[2016-09-14], ~D[2016-09-15]]

        iex> DateRange.new("2016-09-12", 1)
        [~D[2016-09-12]]

        iex> DateRange.new("2016-09-12", 0)
        []

        iex> DateRange.new("2016-09-12", -2)
        []
  """

  def new(_, periods) when periods <= 0 do
    []
  end

  def new(start_date, periods) do
    date = Date.from_iso8601!(start_date)
    Enum.map(0..periods - 1, &Timex.shift(date, days: &1))
  end

end

defmodule DataFrame.DataRange do
  @moduledoc """
    Ranges. This is useful to create columns and indexes.
    It allows numbers and strings. In the future will have more types
  """

  def new(start_data, end_data) when is_number(start_data) and is_number(end_data) do
    Enum.to_list start_data..end_data
  end

  def new(start_data, end_data) when is_binary(start_data) and is_binary(end_data) do
    <<first_letter::utf8>> = start_data
    <<second_letter::utf8>> = end_data
    first_letter..second_letter
      |> Enum.to_list
      |> Enum.map(&(<<&1::utf8>>))
  end

end
