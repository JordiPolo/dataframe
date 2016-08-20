# Dataframe

DataFrame is a library that implements an API similar to [Python's Pandas](http://pandas.pydata.org/) or [R's data.frame()](http://www.r-tutor.com/r-introduction/data-frame).

## Installation

The package can be installed as:

  1. Add `dataframe` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:dataframe, "~> 0.1.0"}]
    end
    ```


## Usage

### Creation
```
iex(1)>  data = DataFrame.new(DataFrame.Table.build_random(6,4), DataFrame.DateRange.new("2016-09-12", 6), [1,3,4,5])
              1             3             4             5
2016-09-12    0.3216495192  0.3061978162  0.5240627861  0.3014870998
2016-09-13    0.7085624128  0.1027917034  0.0274851281  0.4999253931
2016-09-14    0.5409299230  0.7234486655  0.0902951353  0.9265397862
2016-09-15    0.8144437609  0.7566869039  0.5943981962  0.4555049347
2016-09-16    0.0228473208  0.9033617026  0.6984988237  0.9858222366
2016-09-17    0.6401066584  0.2700256640  0.4256911712  0.1085587668
```

### Exploring
```
DataFrame.head(data, 2)
              1             3             4             5
2016-09-12    0.3216495192  0.3061978162  0.5240627861  0.3014870998
2016-09-13    0.7085624128  0.1027917034  0.0274851281  0.4999253931
```

```
DataFrame.tail(data, 1)
              1             3             4             5
2016-09-17    0.6401066584  0.2700256640  0.4256911712  0.1085587668
```

### Transposing

```
DataFrame.transpose(data)
              2016-09-12    2016-09-13    2016-09-14    2016-09-15    2016-09-16    2016-09-17
1             0.3216495192  0.7085624128  0.5409299230  0.8144437609  0.0228473208  0.6401066584
3             0.3061978162  0.1027917034  0.7234486655  0.7566869039  0.9033617026  0.2700256640
4             0.5240627861  0.0274851281  0.0902951353  0.5943981962  0.6984988237  0.4256911712
5             0.3014870998  0.4999253931  0.9265397862  0.4555049347  0.9858222366  0.1085587668
```

### Sorting

Sorting index (defaults bigger to smaller)
```
DataFrame.sort_index(data)
              1             3             4             5
2016-09-17    0.6401066584  0.2700256640  0.4256911712  0.1085587668
2016-09-16    0.0228473208  0.9033617026  0.6984988237  0.9858222366
2016-09-15    0.8144437609  0.7566869039  0.5943981962  0.4555049347
2016-09-14    0.5409299230  0.7234486655  0.0902951353  0.9265397862
2016-09-13    0.7085624128  0.1027917034  0.0274851281  0.4999253931
2016-09-12    0.3216495192  0.3061978162  0.5240627861  0.3014870998
```

Sorting by a column (false to sort smaller to bigger)
```
DataFrame.sort_values(data, 4, false)
              1             3             4             5
2016-09-13    0.7085624128  0.1027917034  0.0274851281  0.4999253931
2016-09-14    0.5409299230  0.7234486655  0.0902951353  0.9265397862
2016-09-17    0.6401066584  0.2700256640  0.4256911712  0.1085587668
2016-09-12    0.3216495192  0.3061978162  0.5240627861  0.3014870998
2016-09-15    0.8144437609  0.7566869039  0.5943981962  0.4555049347
2016-09-16    0.0228473208  0.9033617026  0.6984988237  0.9858222366
```

### Selecting

By name:
```
DataFrame.loc(data, DataFrame.DateRange.new("2016-09-15", 2), [3,4])
              3             4
2016-09-15    0.5417848216  0.5546980818
2016-09-16    0.6621771048  0.5763923325
```
```
DataFrame.at(data, "2016-09-15", 4)
0.5546980818725673
```


By position:
```
DataFrame.iloc(data, 4..6, 2..4)
              4             5
2016-09-16    0.6984988237  0.9858222366
2016-09-17    0.4256911712  0.1085587668
```

```
DataFrame.iat(data, 0, 0)
0.31553155828919915
```

The library is in very early stages of development. No effort has been made to optimize its performance. Expect it to be slow.

## Development

Run tests
```
mix test
```

## TODO

- Example of usage with CSV file
- Finish Statistics module
- Deal with exceptions (negative numbers as input, etc.)
- Setting of subtable data
