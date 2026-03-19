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

[`get_persons`](https://werkstattcodes.github.io/ParlAT/reference/get_persons.md)

## Examples

``` r
# \donttest{
get_pad_intern("Strache")
#> # A tibble: 3 × 2
#>   pad_intern names_variants                         
#>   <chr>      <chr>                                  
#> 1 1905       Max Strache                            
#> 2 35518      Heinz-Christian Strache                
#> 3 44127      Pia Philippa Beck, Pia Philippa Strache
get_pad_intern("Heinz-Christian Strache")
#> # A tibble: 1 × 2
#>   pad_intern names_variants         
#>   <chr>      <chr>                  
#> 1 35518      Heinz-Christian Strache
# }
```
