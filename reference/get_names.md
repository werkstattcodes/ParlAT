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
if (FALSE) { # \dontrun{
get_names(44127) # Philippa Pia Beck, Philippa Pia Strache
get_names(44127, latest = TRUE) # Philippa Pia Beck, formerly Strache
get_names(44127, date = "01/01/2023") # Philippa Pia Strache
# Multiple pad_interns possible:
# e.g. Michael Pock/Bernhard; Freda Blau-Meissner/Meissner-Blau
get_names(c(1130, 83124))
} # }
```
