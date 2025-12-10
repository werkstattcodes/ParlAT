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
  Only considered if no pad_intern(s) provided.

- pad_intern:

  Personal identfication number of person(s). Has to be NULL if name is
  provided.

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
if (FALSE) { # \dontrun{
  get_mandates(c("Elisabeth Götze", "Sebastian Kurz"))
  # Returns results with latest name (Beck)
  get_mandates(c("Pia Philippa Strache"))

  # Michael Pöck changed name to Michael Bernhard.
  get_names(pad_intern = "83124")
  # Query for Micheal Pöck returns all results under the name
  # Michael Bernhard, even for periods where Michael Pöck was still valid.
  get_mandates(name = "Michael Pöck")
  # Query for Michael Bernhard returns all results,
  # including for those with the name Michael Pöck.
  get_mandates(name = "Michael Bernhard")
} # }
```
