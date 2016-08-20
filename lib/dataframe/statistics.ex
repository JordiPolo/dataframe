
defmodule DataFrame.Statistics do
  @moduledoc """
    Functions with statistics processing of Frames
  """
  alias DataFrame.Table
  # Goal is to achieve something like this
  # count  6.000000  6.000000  6.000000  6.000000
  # mean   0.073711 -0.431125 -0.687758 -0.233103
  # std    0.843157  0.922818  0.779887  0.973118
  # min   -0.861849 -2.104569 -1.509059 -1.135632
  # 25%   -0.611510 -0.600794 -1.368714 -1.076610
  # 50%    0.022070 -0.228039 -0.767252 -0.386188
  # 75%    0.658444  0.041933 -0.034326  0.461706
  # max    1.212112  0.567020  0.276232  1.071804
  def describe(frame) do
    values = frame.values |> Table.transpose |> Enum.map(&describe_column/1) |> Table.transpose
    DataFrame.new(values, ["count", "mean", "std", "min", "25%", "max"], frame.columns)
  end

  defp describe_column(column) do
    count = Enum.count(column)
    mean = Enum.sum(column) / count
    min = Enum.min(column)
    max = Enum.max(column)
    variance_sum = column |> Enum.map(fn(x) -> :math.pow((mean - x), 2) end) |> Enum.sum
    std = :math.sqrt(variance_sum / count)
    twenty_five = "23" #percentile(column, 25)
    [count, mean, std, min, twenty_five, max]
  end

  defp percentile(values, percentile) do
    values_sorted = Enum.sort values
    k = percentile * (Enum.count(values_sorted) - 1)
    #Float.floor(percentile*(Enum.count(values_sorted)-1)+1) - 1
    f = mod(percentile * (Enum.count(values_sorted) - 1) + 1, 1)
    Enum.at(values_sorted, k) + (f * (Enum.at(values_sorted, k + 1) - Enum.at(values_sorted, k)))
  end

  # TODO: Stolen from Elixir's 1.4 Integer class, use that class when released
  defp mod(dividend, divisor) do
    remainder = rem(dividend, divisor)
    if remainder * divisor < 0 do
      remainder + divisor
    else
      remainder
    end
  end

end
