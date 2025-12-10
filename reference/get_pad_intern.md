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
if (FALSE) { # \dontrun{
get_pad_intern("Strache")
get_pad_intern("Heinz-Christian Strache")
} # }
```
