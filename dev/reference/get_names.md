# Get name variants of a Member of Parliament

Returns all name variants of an person or a specific name used on a
given date. This function is particularly relevant for MPs who changed
their names (e.g., due to marriage or divorce).

## Usage

``` r
get_names(pad_intern, date = NULL, latest = NULL)
```

## Arguments

- pad_intern:

  The internal identifier for the MP; allows for input of length \>= 1;

- date:

  Optional. A specific date to retrieve the name used at that time. When
  omitted, returns all name variants.

- latest:

  Logical. If TRUE, only the latest name is returned.

## Value

A dataframe containing name variant(s) of the specified person with the
following columns:

- `index`: Sequential index of name variants

- `pad_intern`: Person's unique identification number

- `name`: Full name with titles and formatting

- `date_start`: Start date when this name variant was valid (Date)

- `date_end`: End date when this name variant was valid (Date, NA if
  currently valid)

- `name_clean`: Cleaned version of the name without titles

- `name_family`: Family name/surname

- `name_given`: Given name/first name

- `note`: Raw value from the source data

## See also

[`get_pad_intern()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_pad_intern.md)
to retrieve an MP's `pad_intern`

## Examples

``` r
# \donttest{
result <- get_names(44127) # Philippa Pia Beck, Philippa Pia Strache
dplyr::glimpse(result)
#> Rows: 2
#> Columns: 9
#> $ index       <int> 1, 2
#> $ pad_intern  <dbl> 44127, 44127
#> $ name        <chr> "Pia Philippa Beck", "Pia Philippa Strache"
#> $ date_start  <date> 2023-06-28, NA
#> $ date_end    <date> NA, 2023-06-27
#> $ name_clean  <chr> "Pia Philippa Beck", "Pia Philippa Strache"
#> $ name_family <chr> "Beck", "Strache"
#> $ name_given  <chr> "Pia Philippa ", "Pia Philippa "
#> $ note        <chr> NA, "(bis 27.6.2023: Pia Philippa Strache)"

result <- get_names(44127, latest = TRUE) # Philippa Pia Beck, formerly Strache
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 9
#> $ index       <int> 1
#> $ pad_intern  <dbl> 44127
#> $ name        <chr> "Pia Philippa Beck"
#> $ date_start  <date> 2023-06-28
#> $ date_end    <date> NA
#> $ name_clean  <chr> "Pia Philippa Beck"
#> $ name_family <chr> "Beck"
#> $ name_given  <chr> "Pia Philippa "
#> $ note        <chr> NA

result <- get_names(44127, date = "01/01/2023") # Philippa Pia Strache
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 9
#> $ index       <dbl> 1
#> $ pad_intern  <dbl> 44127
#> $ name        <chr> "Pia Philippa Strache"
#> $ date_start  <date> NA
#> $ date_end    <date> 2023-06-27
#> $ name_clean  <chr> "Pia Philippa Strache"
#> $ name_family <chr> "Strache"
#> $ name_given  <chr> "Pia Philippa "
#> $ note        <chr> "(bis 27.6.2023: Pia Philippa Strache)"

# Multiple pad_interns possible:
# e.g. Michael Pock/Bernhard; Freda Blau-Meissner/Meissner-Blau
result <- get_names(c(1130, 83124))
dplyr::glimpse(result)
#> Rows: 4
#> Columns: 9
#> $ index       <int> 1, 2, 1, 2
#> $ pad_intern  <dbl> 1130, 1130, 83124, 83124
#> $ name        <chr> "Freda Meissner-Blau", "Freda Blau-Meissner", "Michael Ber…
#> $ date_start  <date> 1988-05-12, NA, 2016-08-11, NA
#> $ date_end    <date> NA, 1988-05-11, NA, 2016-08-10
#> $ name_clean  <chr> "Freda Meissner-Blau", "Freda Blau-Meissner", "Michael Ber…
#> $ name_family <chr> "Meissner-Blau", "Blau-Meissner", "Bernhard", "Pock"
#> $ name_given  <chr> "Freda ", "Freda ", "Michael ", "Michael "
#> $ note        <chr> NA, "(bis 11.5.1988: Freda Blau-Meissner)", NA, "(bis 10.8…
# }
```
