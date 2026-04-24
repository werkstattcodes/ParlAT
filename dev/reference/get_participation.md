# Get Participation Data from Austrian Parliament

This function retrieves participation data from the Austrian
Parliament's API based on various filter criteria. For the pertaining
website by the Austrian Parliament see
[here](https://www.parlament.gv.at/beteiligen/stellung-nehmen/?FP_143SNFLAG=J).  
Once a legislative initiative, citizens' initiative, or petition has
been submitted to Parliament, pertaining statements expressing the
author's opinion regarding the pending issue can be submitted. This
allows the author to express his/her opinion and participate in the
parliamentary process. For ministerial drafts, statements can be
submitted during the pre-parliamentary process. Furthermore, statements
of other authors can be supported.

## Usage

``` r
get_participation(
  topic = NULL,
  legis_period = NULL,
  active = NULL,
  item = NULL,
  initiative_type = NULL,
  statement_type = NULL
)
```

## Arguments

- topic:

  (*Themen*) Character vector. Optional. Specifies the topic(s) of
  interest. See details for valid values.

- legis_period:

  (*Gesetzgebungsperiode*) Character vector. Optional. Specifies the
  legislative period(s).

- active:

  (*Aktuelle Beteiligung*) Character. Optional. If "J", only includes
  current participations.

- item:

  (*Gegenstand*) Character vector. Optional. Specifies the type of
  review. See details for valid values.

- initiative_type:

  (*Art der Gesetzesinitiative*) Optional character vector. Only if
  item="RGES" (Gesetzesinitiativen/Legislative Initiatives). Specifies
  the type of legislative initiative. See details for valid values.

- statement_type:

  (*Art der Stellungnahme*) Optional character vector. Only if item="SN"
  (Stellungnahmen/Statements). Specifies the type of statement. See
  details for valid values.

## Value

A tibble containing the participation data with the following columns:

- `legis_period`: Legislative period

- `date`: Date of the participation item (Date class)

- `active`: Indicates if current participation is possible

- `item_id`: Item identifier

- `item_code`: Item type code

- `item`: Description of the item type

- `title`: Title of the participation item

- `type_doc`: Document type

- `topic`: Topic(s) associated with the item

- `item_url`: URL to the item on the Parliament website

- `statements`: Number of statements submitted

- `support`: Number of supporters

- `ministry`: Responsible ministry

Returns NULL if no results are found for the provided search criteria.

## Details

This function sends a request to the Austrian Parliament's API to
retrieve participation data based on the provided filter criteria. It
performs input validation for each parameter and constructs the API
request accordingly.

**Valid values for `topic`:**

- "Arbeit" (Labor)

- "Außenpolitik" (Foreign Policy)

- "Bildung" (Education)

- "Budget und Finanzen" (Budget and Finance)

- "Europäische Union" (European Union)

- "Familie und Generationen" (Family and Generations)

- "Frauen und Gleichbehandlung" (Women and Equal Treatment)

- "Gesundheit und Ernährung" (Health and Nutrition)

- "Information und Medien" (Information and Media)

- "Inneres und Recht" (Interior and Justice)

- "Innovation, Technologie und Forschung" (Innovation, Technology and
  Research)

- "Klima, Umwelt und Energie" (Climate, Environment and Energy)

- "Kultur" (Culture)

- "Land- und Forstwirtschaft" (Agriculture and Forestry)

- "Landesverteidigung" (National Defense)

- "Parlament und Demokratie" (Parliament and Democracy)

- "Soziales" (Social Affairs)

- "Sport" (Sports)

- "Verkehr und Infrastruktur" (Transport and Infrastructure)

- "Wirtschaft" (Economy)

Setting `topic = NULL` returns values for all topics listed above.

**Valid values for `item`:**

- "RGES" (Gesetzesinitiativen / Legislative Initiatives)

- "ME" (Ministerialentwürfe / Ministerial Drafts)

- "BI" (Bürgerinitiativen / Citizens' Initiatives)

- "PET" (Petitionen / Petitions)

- "SN" (Stellungnahmen / Statements) Setting `item = NULL` returns
  values for all review types listed above.

**Valid values for `initiative_type`** (Only if item=="RGES"):

- "A" (Gesetzesanträge von Abgeordneten / Legislative Motions by
  Members)

- "BUA" (Gesetzesanträge von Ausschüssen / Legislative Motions by
  Committees)

- "RV" (Regierungsvorlagen / Government Bills)

Setting `initiative_type = NULL` returns values for all initiative types
listed above.

**Valid values for `statement_type`** (Only if item=="SN"):

- "SNME" (Stellungnahme Ministerialentwurf / Statement on Ministerial
  Draft)

- "SN" (Stellungnahme Gesetzesinitiative / Statement on Legislative
  Initiative)

- "SPET" (Stellungnahme zur Petition / Statement on Petition)

- "SPET-BR" (Stellungnahme zur Petition Bundesrat / Statement on
  Petition Federal Council)

- "SBI" (Stellungnahme Bürgerinitiative / Statement on Citizens'
  Initiative)

Setting `statement_type = NULL` returns values for all statement types
listed above.

## Examples

``` r
# \donttest{
# Get participation data for the topic "Bildung"
result <- get_participation(topic = "Bildung")
dplyr::glimpse(result)
#> Rows: 14,868
#> Columns: 11
#> $ legis_period <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII…
#> $ date         <date> 2026-02-16, 2025-12-18, 2026-03-19, 2025-12-23, 2026-03-…
#> $ active       <chr> "J", "N", "N", "N", "N", "J", "N", "J", "N", "N", "J", "J…
#> $ item_id      <chr> "32/BI", "2/SN-69/ME", "1056/SN", "19/SN-69/ME", "1052/SN…
#> $ item_code    <chr> "BI", "SNME", "SN", "SNME", "SN", "PET", "SN", "SN", "SNM…
#> $ item         <chr> "Bürgerinitiative", "Stellungnahme", "Stellungnahme", "St…
#> $ title        <chr> "Unsere Kinder brauchen Unterstützung JETZT und nicht irg…
#> $ topic        <chr> "[\"Bildung\",\"Inneres und Recht\",\"Parlament und Demok…
#> $ item_url     <chr> "/gegenstand/XXVIII/BI/32", "/gegenstand/XXVIII/SNME/2825…
#> $ statements   <chr> "44", "0", "0", "0", "0", "1", "0", "0", "0", "0", "0", "…
#> $ ministry     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…

# Get participation data for multiple topics and legislative periods
result <- get_participation(
  topic = c("Arbeit", "Soziales"),
  legis_period = c("27", "26"),
  item = "RGES"
)
dplyr::glimpse(result)
#> Rows: 467
#> Columns: 11
#> $ legis_period <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVI", "XXVI", "XXVI…
#> $ date         <date> 2020-09-21, 2020-07-03, 2023-07-03, 2023-07-03, 2018-05-…
#> $ active       <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ item_id      <chr> "371 d.B.", "320 d.B.", "2152 d.B.", "2147 d.B.", "140 d.…
#> $ item_code    <chr> "I", "I", "I", "I", "I", "I", "A", "A", "A", "A", "A", "A…
#> $ item         <chr> "Gesetzesinitiative", "Gesetzesinitiative", "Gesetzesinit…
#> $ title        <chr> "Allgemeines Sozialversicherungsgesetz, Gewerbliches Sozi…
#> $ topic        <chr> "[\"Gesundheit und Ernährung\",\"Inneres und Recht\",\"So…
#> $ item_url     <chr> "/gegenstand/XXVII/I/371", "/gegenstand/XXVII/I/320", "/g…
#> $ statements   <chr> "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "1…
#> $ ministry     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…

# Get participation data on all ministerial drafts for legislative periods 26 and 27
result <- get_participation(
  legis_period = c(26, 27),
  item = "ME"
)
dplyr::glimpse(result)
#> Rows: 516
#> Columns: 11
#> $ legis_period <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XX…
#> $ date         <date> 2022-05-31, 2022-05-31, 2022-05-31, 2022-06-09, 2022-08-…
#> $ active       <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ item_id      <chr> "204/ME", "205/ME", "206/ME", "211/ME", "222/ME", "225/ME…
#> $ item_code    <chr> "ME", "ME", "ME", "ME", "ME", "ME", "ME", "ME", "ME", "ME…
#> $ item         <chr> "Ministerialentwurf", "Ministerialentwurf", "Ministeriale…
#> $ title        <chr> "Bundespflegegeldgesetz, Änderung (204/ME)", "Entgelterhö…
#> $ topic        <chr> "[\"Gesundheit und Ernährung\",\"Soziales\"]", "[\"Arbeit…
#> $ item_url     <chr> "/gegenstand/XXVII/ME/204", "/gegenstand/XXVII/ME/205", "…
#> $ statements   <chr> "40", "98", "39", "10", "11", "26", "56", "30", "21", "8"…
#> $ ministry     <chr> "BMSGPK", "BMSGPK", "BMSGPK", "BMSGPK", "BMSGPK", "BMSGPK…

# Get participation data on legislative initiatives with specific initiative type
result <- get_participation(
  item = "RGES",
  initiative_type = "RV"
)
dplyr::glimpse(result)
#> Rows: 7,772
#> Columns: 11
#> $ legis_period <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XX…
#> $ date         <date> 2021-05-12, 2020-11-11, 2020-11-18, 2021-03-17, 2020-11-…
#> $ active       <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ item_id      <chr> "849 d.B.", "461 d.B.", "468 d.B.", "732 d.B.", "482 d.B.…
#> $ item_code    <chr> "I", "I", "I", "I", "I", "I", "I", "I", "I", "I", "I", "I…
#> $ item         <chr> "Gesetzesinitiative", "Gesetzesinitiative", "Gesetzesinit…
#> $ title        <chr> "Terror-Bekämpfungs-Gesetz – TeBG (849 d.B.)", "Dienstrec…
#> $ topic        <chr> "[\"Inneres und Recht\"]", "[\"Gesundheit und Ernährung\"…
#> $ item_url     <chr> "/gegenstand/XXVII/I/849", "/gegenstand/XXVII/I/461", "/g…
#> $ statements   <chr> "0", "0", "0", "0", "0", "0", "0", "0", "2", "0", "0", "0…
#> $ ministry     <chr> NA, NA, NA, NA, NA, NA, "BMDW", NA, NA, NA, NA, NA, "BMK"…
# }
```
