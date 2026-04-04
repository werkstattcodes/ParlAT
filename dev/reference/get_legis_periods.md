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
# \donttest{
# Numeric periods
result <- get_legis_periods(legis_period = 27)
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 8
#> $ legis_period_rom        <chr> "XXVII"
#> $ legis_period            <dbl> 27
#> $ legis_period_current    <lgl> FALSE
#> $ date_start              <date> 2019-10-23
#> $ date_end                <date> 2024-10-23
#> $ legis_period_name       <glue> "23.10.2019 - 23.10.2024: XXVII. GP"
#> $ legis_period_abbrev     <chr> "XXVII"
#> $ legis_period_abbrev_num <chr> "27"

result <- get_legis_periods(legis_period = c(26, 27))
dplyr::glimpse(result)
#> Rows: 2
#> Columns: 8
#> $ legis_period_rom        <chr> "XXVI", "XXVII"
#> $ legis_period            <dbl> 26, 27
#> $ legis_period_current    <lgl> FALSE, FALSE
#> $ date_start              <date> 2017-11-09, 2019-10-23
#> $ date_end                <date> 2019-10-22, 2024-10-23
#> $ legis_period_name       <glue> "09.11.2017 - 22.10.2019: XXVI. GP", "23.10.20…
#> $ legis_period_abbrev     <chr> "XXVI", "XXVII"
#> $ legis_period_abbrev_num <chr> "26", "27"

# Roman numerals
result <- get_legis_periods(legis_period = "XXVII")
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 8
#> $ legis_period_rom        <chr> "XXVII"
#> $ legis_period            <dbl> 27
#> $ legis_period_current    <lgl> FALSE
#> $ date_start              <date> 2019-10-23
#> $ date_end                <date> 2024-10-23
#> $ legis_period_name       <glue> "23.10.2019 - 23.10.2024: XXVII. GP"
#> $ legis_period_abbrev     <chr> "XXVII"
#> $ legis_period_abbrev_num <chr> "27"

# Historical periods
result <- get_legis_periods(legis_period = "PN")
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 8
#> $ legis_period_rom        <chr> NA
#> $ legis_period            <dbl> NA
#> $ legis_period_current    <lgl> FALSE
#> $ date_start              <date> 1918-10-21
#> $ date_end                <date> 1919-02-16
#> $ legis_period_name       <glue> "21.10.1918 - 16.02.1919: Provisorische Nation…
#> $ legis_period_abbrev     <chr> "PN"
#> $ legis_period_abbrev_num <chr> "PN"

# Mixed input types
result <- get_legis_periods(legis_period = c(26, "XXVII", "PN"))
dplyr::glimpse(result)
#> Rows: 3
#> Columns: 8
#> $ legis_period_rom        <chr> NA, "XXVI", "XXVII"
#> $ legis_period            <dbl> NA, 26, 27
#> $ legis_period_current    <lgl> FALSE, FALSE, FALSE
#> $ date_start              <date> 1918-10-21, 2017-11-09, 2019-10-23
#> $ date_end                <date> 1919-02-16, 2019-10-22, 2024-10-23
#> $ legis_period_name       <glue> "21.10.1918 - 16.02.1919: Provisorische Nation…
#> $ legis_period_abbrev     <chr> "PN", "XXVI", "XXVII"
#> $ legis_period_abbrev_num <chr> "PN", "26", "27"

# Filter by date
result <- get_legis_periods(date = "01.01.2020")
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 7
#> $ legis_period            <dbl> 27
#> $ legis_period_current    <lgl> FALSE
#> $ date_start              <date> 2019-10-23
#> $ date_end                <date> 2024-10-23
#> $ legis_period_name       <glue> "23.10.2019 - 23.10.2024: XXVII. GP"
#> $ legis_period_abbrev     <chr> "XXVII"
#> $ legis_period_abbrev_num <chr> "27"
# }
```
