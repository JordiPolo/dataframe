
defmodule Benchmark do

  def check do
#    aa = DataFrame.new(DataFrame.Table.build_random(6000,4), [1,3,4,5], DataFrame.DateRange.new("2016-09-12", 6000) )
#    rows = Enum.to_list(1..6000)
#    columns = [1,2,3,4]
#    bb = create(%{}, rows, columns)
    aa = DataFrame.new(DataFrame.Table.build_random(6000,4), [1,3,4,5], DataFrame.DateRange.new("2016-09-12", 6000) )
    index = Enum.to_list 1..6000

    dataframe = DataFrame.new(aa.values, aa.columns, index)
    dataframe_map = DataFrameMap.new(aa.values, aa.columns, index)

    Benchee.run(%{time: 2}, %{
      "transpose(list of lists)"  => fn -> DataFrame.transpose(dataframe) end,
      "transpose(maps)" => fn -> DataFrameMap.transpose(dataframe_map) end
    })

    Benchee.run(%{time: 2}, %{
      "tail(list of lists)"  => fn -> DataFrame.tail(dataframe) end,
      "tail(maps)" => fn -> DataFrameMap.tail(dataframe_map) end
    })

     Benchee.run(%{time: 2}, %{
      "rows(list of lists)"  => fn -> DataFrame.rows(dataframe, 1..1000) end,
      "rows(maps)" => fn -> DataFrameMap.rows(dataframe_map, 1..1000) end
    })

    Benchee.run(%{time: 2}, %{
      "columns(list of lists)"  => fn -> DataFrame.columns(dataframe, 1..3) end,
      "columns(maps)" => fn -> DataFrameMap.columns(dataframe_map, 1..3) end
    })
  end
end
