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

[`get_pad_intern()`](https://werkstattcodes.github.io/ParlAT/reference/get_pad_intern.md)
to retrieve an MP's `pad_intern`

## Examples

``` r
# \donttest{
get_names(44127) # Philippa Pia Beck, Philippa Pia Strache
#>   index pad_intern                 name date_start   date_end
#> 1     1      44127    Pia Philippa Beck 2023-06-28       <NA>
#> 2     2      44127 Pia Philippa Strache       <NA> 2023-06-27
#>             name_clean name_family    name_given
#> 1    Pia Philippa Beck        Beck Pia Philippa 
#> 2 Pia Philippa Strache     Strache Pia Philippa 
#>                                    note
#> 1                                  <NA>
#> 2 (bis 27.6.2023: Pia Philippa Strache)
get_names(44127, latest = TRUE) # Philippa Pia Beck, formerly Strache
#>   index pad_intern              name date_start date_end        name_clean
#> 1     1      44127 Pia Philippa Beck 2023-06-28     <NA> Pia Philippa Beck
#>   name_family    name_given note
#> 1        Beck Pia Philippa  <NA>
get_names(44127, date = "01/01/2023") # Philippa Pia Strache
#>   index pad_intern                 name date_start   date_end
#> 1     1      44127 Pia Philippa Strache       <NA> 2023-06-27
#>             name_clean name_family    name_given
#> 1 Pia Philippa Strache     Strache Pia Philippa 
#>                                    note
#> 1 (bis 27.6.2023: Pia Philippa Strache)
# Multiple pad_interns possible:
# e.g. Michael Pock/Bernhard; Freda Blau-Meissner/Meissner-Blau
get_names(c(1130, 83124))
#>   index pad_intern                name date_start   date_end
#> 1     1       1130 Freda Meissner-Blau 1988-05-12       <NA>
#> 2     2       1130 Freda Blau-Meissner       <NA> 1988-05-11
#> 3     1      83124    Michael Bernhard 2016-08-11       <NA>
#> 4     2      83124        Michael Pock       <NA> 2016-08-10
#>            name_clean   name_family name_given
#> 1 Freda Meissner-Blau Meissner-Blau     Freda 
#> 2 Freda Blau-Meissner Blau-Meissner     Freda 
#> 3    Michael Bernhard      Bernhard   Michael 
#> 4        Michael Pock          Pock   Michael 
#>                                   note
#> 1                                 <NA>
#> 2 (bis 11.5.1988: Freda Blau-Meissner)
#> 3                                 <NA>
#> 4        (bis 10.8.2016: Michael Pock)
# }
```
