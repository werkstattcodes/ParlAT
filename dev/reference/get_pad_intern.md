# Get unique identificiaton number (pad_intern)

Get unique identificiaton number (pad_intern)

## Usage

``` r
get_pad_intern(name)
```

## Arguments

- name:

  Character vector of length 1. Name of the person in the format first
  name last name, or only family name.

## Value

A dataframe with the unique identification number (pad_intern) and
person's current and previous names.

## See also

[`get_persons`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_persons.md)

## Examples

``` r
# \donttest{
result <- get_pad_intern("Strache")
dplyr::glimpse(result)
#> Rows: 3
#> Columns: 2
#> $ pad_intern     <chr> "1905", "35518", "44127"
#> $ names_variants <chr> "Max Strache", "Heinz-Christian Strache", "Pia Philippa…

result <- get_pad_intern("Heinz-Christian Strache")
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 2
#> $ pad_intern     <chr> "35518"
#> $ names_variants <chr> "Heinz-Christian Strache"
# }
```
