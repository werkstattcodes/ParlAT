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

  When no mandates match, a zero-row tibble with the same columns and
  column types is returned.

## Details

### Names: The API will always return the latest name of an MP, even if the MP had a different name at a previous point in time.

See examples.

## See also

[`get_names()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_names.md),
[`get_pad_intern()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_pad_intern.md)

## Examples

``` r
# \donttest{
  result <- get_mandates(c("Elisabeth Götze", "Sebastian Kurz"))
  dplyr::glimpse(result)
#> Rows: 10
#> Columns: 16
#> $ pad_intern                     <chr> "5654", "65321", "65321", "65321", "653…
#> $ name                           <chr> "Dr. Elisabeth Götze", "Sebastian Kurz"…
#> $ position_text                  <chr> "Abgeordnete zum Nationalrat (XXVII.-XX…
#> $ position_code                  <chr> "NR", "NR", "NR", "NR", "NR", "BK", "BK…
#> $ position_name                  <chr> "Abgeordnete zum Nationalrat", "Abgeord…
#> $ position_date_start            <date> 2019-10-23, 2021-10-14, 2019-10-23, 20…
#> $ position_date_end              <date> NA, 2021-12-08, 2020-01-07, 2018-01-22…
#> $ position_active                <lgl> TRUE, FALSE, FALSE, FALSE, FALSE, FALSE…
#> $ parl_group                     <chr> "Der Grüne Klub im Parlament - Klub der…
#> $ party                          <chr> "GRÜNE", "ÖVP", "ÖVP", "ÖVP", "ÖVP", NA…
#> $ party_name                     <chr> "Die Grünen", "Österreichische Volkspar…
#> $ substitute                     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
#> $ electoral_district_region_code <chr> "3", "FB", "FB", "FB", "9E", NA, NA, NA…
#> $ electoral_district_region      <chr> "Niederösterreich", "Bundeswahlvorschla…
#> $ legis_period                   <list> <"XXVII", "XXVIII">, "XXVII", "XXVII", …
#> $ url_biography                  <chr> "https://www.parlament.gv.at/person/56…

  # Returns results with latest name (Beck)
  result <- get_mandates(c("Pia Philippa Strache"))
  dplyr::glimpse(result)
#> Rows: 1
#> Columns: 16
#> $ pad_intern                     <chr> "44127"
#> $ name                           <chr> "Pia Philippa Beck"
#> $ position_text                  <chr> "Abgeordnete zum Nationalrat (XXVII. GP…
#> $ position_code                  <chr> "NR"
#> $ position_name                  <chr> "Abgeordnete zum Nationalrat"
#> $ position_date_start            <date> 2019-10-23
#> $ position_date_end              <date> 2024-10-23
#> $ position_active                <lgl> FALSE
#> $ parl_group                     <chr> "ohne Klubzugehörigkeit"
#> $ party                          <chr> "OK"
#> $ party_name                     <chr> "Freiheitliche Partei Österreichs"
#> $ substitute                     <chr> NA
#> $ electoral_district_region_code <chr> "9"
#> $ electoral_district_region      <chr> "Wien"
#> $ legis_period                   <list> "XXVII"
#> $ url_biography                  <chr> "https://www.parlament.gv.at/person/441…

  # Michael Pock changed name to Michael Bernhard.
  result <- get_names(pad_intern = "83124")
  dplyr::glimpse(result)
#> Rows: 2
#> Columns: 9
#> $ index       <int> 1, 2
#> $ pad_intern  <chr> "83124", "83124"
#> $ name        <chr> "Michael Bernhard", "Michael Pock"
#> $ date_start  <date> 2016-08-11, NA
#> $ date_end    <date> NA, 2016-08-10
#> $ name_clean  <chr> "Michael Bernhard", "Michael Pock"
#> $ name_family <chr> "Bernhard", "Pock"
#> $ name_given  <chr> "Michael ", "Michael "
#> $ note        <chr> NA, "(bis 10.8.2016: Michael Pock)"

  # Query for Michael Pock returns all results under the name
  # Michael Bernhard, even for periods where Michael Pock was still valid.
  result <- get_mandates(name = "Michael Pock")
  dplyr::glimpse(result)
#> Rows: 2
#> Columns: 16
#> $ pad_intern                     <chr> "83124", "83124"
#> $ name                           <chr> "Michael Bernhard", "Michael Bernhard"
#> $ position_text                  <chr> "Abgeordneter zum Nationalrat (XXV.-XXV…
#> $ position_code                  <chr> "NR", "NR"
#> $ position_name                  <chr> "Abgeordneter zum Nationalrat", "Abgeor…
#> $ position_date_start            <date> 2014-01-30, 2013-10-29
#> $ position_date_end              <date> NA, 2014-01-29
#> $ position_active                <lgl> TRUE, FALSE
#> $ parl_group                     <chr> "NEOS Parlamentsklub", "Klub von NEOS u…
#> $ party                          <chr> "NEOS", "NEOS-LIF"
#> $ party_name                     <chr> "NEOS - Das neue Österreich und Liberal…
#> $ substitute                     <chr> "Das durch Mandatsverzicht von Frau Abg…
#> $ electoral_district_region_code <chr> "9", "9"
#> $ electoral_district_region      <chr> "Wien", "Wien"
#> $ legis_period                   <list> <"XXV", "XXVIII">, "XXV"
#> $ url_biography                  <chr> "https://www.parlament.gv.at/person/83…

  # Query for Michael Bernhard returns all results,
  # including for those with the name Michael Pock.
  result <- get_mandates(name = "Michael Bernhard")
  dplyr::glimpse(result)
#> Rows: 2
#> Columns: 16
#> $ pad_intern                     <chr> "83124", "83124"
#> $ name                           <chr> "Michael Bernhard", "Michael Bernhard"
#> $ position_text                  <chr> "Abgeordneter zum Nationalrat (XXV.-XXV…
#> $ position_code                  <chr> "NR", "NR"
#> $ position_name                  <chr> "Abgeordneter zum Nationalrat", "Abgeor…
#> $ position_date_start            <date> 2014-01-30, 2013-10-29
#> $ position_date_end              <date> NA, 2014-01-29
#> $ position_active                <lgl> TRUE, FALSE
#> $ parl_group                     <chr> "NEOS Parlamentsklub", "Klub von NEOS u…
#> $ party                          <chr> "NEOS", "NEOS-LIF"
#> $ party_name                     <chr> "NEOS - Das neue Österreich und Liberal…
#> $ substitute                     <chr> "Das durch Mandatsverzicht von Frau Abg…
#> $ electoral_district_region_code <chr> "9", "9"
#> $ electoral_district_region      <chr> "Wien", "Wien"
#> $ legis_period                   <list> <"XXV", "XXVIII">, "XXV"
#> $ url_biography                  <chr> "https://www.parlament.gv.at/person/83…
# }
```
