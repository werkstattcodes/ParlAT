# Get mandates

Takes one or multiple names or pad_interns as input and returns a
dataframe with all their past and present mandates. Mandates can be
limited to a specific date or institution. Mandates cover memberships in
Parliament, but also in the executive (e.g. Bundeskanzler/Chancellor).

Note that a single row in the returned dataframe can represent e.g.
multiple mandates in e.g. the Nationalrat if they were consecutively
held.

The function partly mimics the behavior of the 'Personensuche' on the
website of the Parliament
([here](https://www.parlament.gv.at/recherchieren/personen/)).

## Usage

``` r
get_mandates(name = NULL, pad_intern = NULL, institution = NULL, date = NULL)
```

## Arguments

- name:

  A character vector of name(s). First name followed by family name.
  Cannot be combined with `pad_intern`; one of the two must be provided.

- pad_intern:

  Personal identfication number of person(s). Cannot be combined with
  `name`; one of the two must be provided.

- institution:

  Chamber of Parliament. "NR" (Nationalrat), "BR" (Bundesrat), "KN"
  (Konstituierende Nationalversammlung), or "PN" (Provisorische
  Nationalversammlung). NULL covers all institutions. Note that e.g.
  "NR" does not only return MP's mandates, but also presidents of the
  National Council, Secretaries ("Schriftführer"), and Regulators
  ("Ordner"). The equivalent applies to other the chambers as well.

- date:

  Date to filter mandates (dmy format).

## Value

A dataframe with the following columns:

- `pad_intern`: Person's unique identification number

- `name`: Name of the person

- `position_text`: Full description of the position

- `position_code`: Code for the position type

- `position_name`: Name of the position/function

- `position_date_start`: Start date of the position (Date)

- `position_date_end`: End date of the position (Date, NA if currently
  active)

- `position_active`: Logical indicating if the position is currently
  active

- `parl_group`: Parliamentary group affiliation

- `party`: Political party code

- `party_name`: Full name of the political party

- `substitute`: Information about substitute status

- `electoral_district_region_code`: Electoral district region code

- `electoral_district_region`: Electoral district region name

- `legis_period`: Legislative period(s) (list-column)

- `url_biography`: URL to the person's biography page

## Details

### Names: The API will always return the latest name of an MP, even if the MP had a different name at a previous point in time.

See examples.

## See also

[`get_names()`](https://werkstattcodes.github.io/ParlAT/reference/get_names.md),
[`get_pad_intern()`](https://werkstattcodes.github.io/ParlAT/reference/get_pad_intern.md)

## Examples

``` r
# \donttest{
  get_mandates(c("Elisabeth Götze", "Sebastian Kurz"))
#> # A tibble: 10 × 16
#>    pad_intern name                position_text      position_code position_name
#>    <chr>      <chr>               <chr>              <chr>         <chr>        
#>  1 5654       Dr. Elisabeth Götze Abgeordnete zum N… NR            Abgeordnete …
#>  2 65321      Sebastian Kurz      Abgeordneter zum … NR            Abgeordneter…
#>  3 65321      Sebastian Kurz      Abgeordneter zum … NR            Abgeordneter…
#>  4 65321      Sebastian Kurz      Abgeordneter zum … NR            Abgeordneter…
#>  5 65321      Sebastian Kurz      Abgeordneter zum … NR            Abgeordneter…
#>  6 65321      Sebastian Kurz      Bundeskanzler      BK            Bundeskanzler
#>  7 65321      Sebastian Kurz      Bundeskanzler      BK            Bundeskanzler
#>  8 65321      Sebastian Kurz      Bundesminister fü… BM            Bundesminist…
#>  9 65321      Sebastian Kurz      Bundesminister fü… BM            Bundesminist…
#> 10 65321      Sebastian Kurz      Staatssekretär im… STS           Staatssekret…
#> # ℹ 11 more variables: position_date_start <date>, position_date_end <date>,
#> #   position_active <lgl>, parl_group <chr>, wahlkreis <chr>, party <chr>,
#> #   party_name <chr>, electoral_district_region_code <chr>,
#> #   electoral_district_region <chr>, legis_period <list>, url_biography <chr>
  # Returns results with latest name (Beck)
  get_mandates(c("Pia Philippa Strache"))
#> # A tibble: 1 × 16
#>   pad_intern name  position_text position_code position_name position_date_start
#>   <chr>      <chr> <chr>         <chr>         <chr>         <date>             
#> 1 44127      Pia … Abgeordnete … NR            Abgeordnete … 2019-10-23         
#> # ℹ 10 more variables: position_date_end <date>, position_active <lgl>,
#> #   parl_group <chr>, wahlkreis <chr>, party <chr>, party_name <chr>,
#> #   electoral_district_region_code <chr>, electoral_district_region <chr>,
#> #   legis_period <list>, url_biography <chr>

  # Michael Pöck changed name to Michael Bernhard.
  get_names(pad_intern = "83124")
#>   index pad_intern             name date_start   date_end       name_clean
#> 1     1      83124 Michael Bernhard 2016-08-11       <NA> Michael Bernhard
#> 2     2      83124     Michael Pock       <NA> 2016-08-10     Michael Pock
#>   name_family name_given                          note
#> 1    Bernhard   Michael                           <NA>
#> 2        Pock   Michael  (bis 10.8.2016: Michael Pock)
  # Query for Micheal Pöck returns all results under the name
  # Michael Bernhard, even for periods where Michael Pöck was still valid.
  get_mandates(name = "Michael Pöck")
#> No mandates found.
#> NULL
  # Query for Michael Bernhard returns all results,
  # including for those with the name Michael Pöck.
  get_mandates(name = "Michael Bernhard")
#> # A tibble: 2 × 17
#>   pad_intern name  position_text position_code position_name position_date_start
#>   <chr>      <chr> <chr>         <chr>         <chr>         <date>             
#> 1 83124      Mich… Abgeordneter… NR            Abgeordneter… 2014-01-30         
#> 2 83124      Mich… Abgeordneter… NR            Abgeordneter… 2013-10-29         
#> # ℹ 11 more variables: position_date_end <date>, position_active <lgl>,
#> #   parl_group <chr>, wahlkreis <chr>, party <chr>, party_name <chr>,
#> #   substitute <chr>, electoral_district_region_code <chr>,
#> #   electoral_district_region <chr>, legis_period <list>, url_biography <chr>
# }
```
