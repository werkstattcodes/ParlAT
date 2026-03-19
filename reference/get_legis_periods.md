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
get_legis_periods(legis_period = 27)
#>   legis_period_rom legis_period legis_period_current date_start   date_end
#> 1            XXVII           27                FALSE 2019-10-23 2024-10-23
#>                    legis_period_name legis_period_abbrev
#> 1 23.10.2019 - 23.10.2024: XXVII. GP               XXVII
#>   legis_period_abbrev_num
#> 1                      27
get_legis_periods(legis_period = c(26, 27))
#>   legis_period_rom legis_period legis_period_current date_start   date_end
#> 1             XXVI           26                FALSE 2017-11-09 2019-10-22
#> 2            XXVII           27                FALSE 2019-10-23 2024-10-23
#>                    legis_period_name legis_period_abbrev
#> 1  09.11.2017 - 22.10.2019: XXVI. GP                XXVI
#> 2 23.10.2019 - 23.10.2024: XXVII. GP               XXVII
#>   legis_period_abbrev_num
#> 1                      26
#> 2                      27

# Roman numerals
get_legis_periods(legis_period = "XXVII")
#>   legis_period_rom legis_period legis_period_current date_start   date_end
#> 1            XXVII           27                FALSE 2019-10-23 2024-10-23
#>                    legis_period_name legis_period_abbrev
#> 1 23.10.2019 - 23.10.2024: XXVII. GP               XXVII
#>   legis_period_abbrev_num
#> 1                      27
get_legis_periods(legis_period = c("XXVI", "XXVII"))
#>   legis_period_rom legis_period legis_period_current date_start   date_end
#> 1             XXVI           26                FALSE 2017-11-09 2019-10-22
#> 2            XXVII           27                FALSE 2019-10-23 2024-10-23
#>                    legis_period_name legis_period_abbrev
#> 1  09.11.2017 - 22.10.2019: XXVI. GP                XXVI
#> 2 23.10.2019 - 23.10.2024: XXVII. GP               XXVII
#>   legis_period_abbrev_num
#> 1                      26
#> 2                      27

# Historical periods
get_legis_periods(legis_period = "PN")
#>   legis_period_rom legis_period legis_period_current date_start   date_end
#> 1             <NA>           NA                FALSE 1918-10-21 1919-02-16
#>                                            legis_period_name
#> 1 21.10.1918 - 16.02.1919: Provisorische Nationalversammlung
#>   legis_period_abbrev legis_period_abbrev_num
#> 1                  PN                      PN
get_legis_periods(legis_period = c("PN", "KN"))
#>   legis_period_rom legis_period legis_period_current date_start   date_end
#> 1             <NA>           NA                FALSE 1918-10-21 1919-02-16
#> 2             <NA>           NA                FALSE 1919-03-04 1920-11-09
#>                                              legis_period_name
#> 1   21.10.1918 - 16.02.1919: Provisorische Nationalversammlung
#> 2 04.03.1919 - 09.11.1920: Konstituierende Nationalversammlung
#>   legis_period_abbrev legis_period_abbrev_num
#> 1                  PN                      PN
#> 2                  KN                      KN

# Mixed input types
get_legis_periods(legis_period = c(26, "XXVII", "PN"))
#>   legis_period_rom legis_period legis_period_current date_start   date_end
#> 1             <NA>           NA                FALSE 1918-10-21 1919-02-16
#> 2             XXVI           26                FALSE 2017-11-09 2019-10-22
#> 3            XXVII           27                FALSE 2019-10-23 2024-10-23
#>                                            legis_period_name
#> 1 21.10.1918 - 16.02.1919: Provisorische Nationalversammlung
#> 2                          09.11.2017 - 22.10.2019: XXVI. GP
#> 3                         23.10.2019 - 23.10.2024: XXVII. GP
#>   legis_period_abbrev legis_period_abbrev_num
#> 1                  PN                      PN
#> 2                XXVI                      26
#> 3               XXVII                      27

# Filter by date
get_legis_periods(date = "01.01.2020")
#>   legis_period legis_period_current date_start   date_end
#> 1           27                FALSE 2019-10-23 2024-10-23
#>                    legis_period_name legis_period_abbrev
#> 1 23.10.2019 - 23.10.2024: XXVII. GP               XXVII
#>   legis_period_abbrev_num
#> 1                      27
get_legis_periods(date = c("01.01.2020", "05.05.1954"))
#>   legis_period legis_period_current date_start   date_end
#> 1            7                FALSE 1953-03-18 1956-06-08
#> 2           27                FALSE 2019-10-23 2024-10-23
#>                    legis_period_name legis_period_abbrev
#> 1   18.03.1953 - 08.06.1956: VII. GP                 VII
#> 2 23.10.2019 - 23.10.2024: XXVII. GP               XXVII
#>   legis_period_abbrev_num
#> 1                       7
#> 2                      27
# }
```
