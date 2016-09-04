defimpl Inspect, for: DataFrame.Frame do
  import Inspect.Algebra
  alias DataFrame.Table

  def inspect(frame, _) do
    headers = ["" | frame.columns]
      |> Enum.map(&(pad(&1)))
      |> Enum.join("")

    data_string = frame.values
      |> Table.add_column(frame.index)
      |> Table.map(&pad(&1))
      |> Enum.map(&(Enum.join(&1 , "")))
      |> Enum.join("\n")

    concat [headers, "\n", data_string]
  end

  defp pad(element) do
    max_characters = 11
    range = 0..max_characters
    element
      |> to_string
      |> String.pad_trailing(max_characters)
      |> String.slice(range)
      |> String.pad_trailing(max_characters + 3)
  end
end
