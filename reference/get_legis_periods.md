# Get start and end dates of legislative periods.

Get start and end dates of legislative periods.

## Usage

``` r
get_legis_periods(legis_period = NULL, date = NULL)
```

## Arguments

- legis_period:

  Number or identifier of legislative period(s) for which dates should
  be returned. Accepts numeric values (e.g., 27), Roman numerals (e.g.,
  "XXVII"), or historical period abbreviations: "PN" (Provisorische
  Nationalversammlung), "KN" (Konstituierende Nationalversammlung),
  "Bundesrat1Rep" (Bundesrat der 1. Republik). Can be a vector for
  multiple periods.

- date:

  Date within a legislative period. Format should be "dd.mm.yyyy".

## Value

A dataframe with the following columns:

- `legis_period_rom`: Legislative period in Roman numerals

- `legis_period`: Legislative period as numeric value

- `legis_period_current`: Logical indicating if this is the current
  period

- `date_start`: Start date of the legislative period (Date)

- `date_end`: End date of the legislative period (Date, NA if current)

- `legis_period_name`: Name/description of the legislative period

## Examples

``` r
if (FALSE) { # \dontrun{
# Numeric periods
get_legis_periods(legis_period = 27)
get_legis_periods(legis_period = c(26, 27))

# Roman numerals
get_legis_periods(legis_period = "XXVII")
get_legis_periods(legis_period = c("XXVI", "XXVII"))

# Historical periods
get_legis_periods(legis_period = "PN")
get_legis_periods(legis_period = c("PN", "KN"))

# Mixed input types
get_legis_periods(legis_period = c(26, "XXVII", "PN"))

# Filter by date
get_legis_periods(date = "01.01.2020")
get_legis_periods(date = c("01.01.2020", "05.05.1954"))
} # }
```
