
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
    DataFrame.new(values, ["count", "mean", "std", "min", "25%", "50%", "75%", "max"], frame.columns)
  end

  defp describe_column(column) do
    count = Enum.count(column)
    mean = Enum.sum(column) / count
    min = Enum.min(column)
    max = Enum.max(column)
    variance_sum = column |> Enum.map(fn(x) -> :math.pow((mean - x), 2) end) |> Enum.sum
    std = :math.sqrt(variance_sum / count)
    twenty_five = percentile(column, 0.25)
    fifty = percentile(column, 0.5)
    seventy_five = percentile(column, 0.75)
    [count, mean, std, min, twenty_five, fifty, seventy_five, max]
  end

  defp percentile(values, percentile) do
    values_sorted = Enum.sort values
    # Given we have for instance 80 elements, this is something like 36.2
    k = percentile * (Enum.count(values_sorted) - 1)
    previous_index = round(Float.floor(k))
    next_index = round(Float.ceil(k))

    # Then this would be 0.2 and whatever number is in the 36th position
    previous_number_weight = k - previous_index
    previous_number = Enum.at(values_sorted, previous_index)

    # And this would be 0.8 and the number in that position
    next_number_weight = next_index - k
    next_number = Enum.at(values_sorted, next_index)

    # Weight sum the previous calculations
    previous_number_weight * previous_number + next_number_weight * next_number
  end

end
