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

Returns a zero-row tibble with the documented columns if no results are
found.

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
#> Rows: 15,003
#> Columns: 11
#> $ legis_period <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII…
#> $ date         <date> 2025-12-18, 2026-03-19, 2025-12-23, 2026-03-13, 2026-02-…
#> $ active       <chr> "N", "N", "N", "N", "J", "N", "N", "N", "J", "N", "J", "J…
#> $ item_id      <chr> "2/SN-69/ME", "1056/SN", "19/SN-69/ME", "1052/SN", "32/BI…
#> $ item_code    <chr> "SNME", "SN", "SNME", "SN", "BI", "SN", "SNME", "SN", "SB…
#> $ item         <chr> "Stellungnahme", "Stellungnahme", "Stellungnahme", "Stell…
#> $ title        <chr> "Privatschulgesetz; Änderung (2/SN-69/ME)", "Stellungnahm…
#> $ topic        <chr> "[\"Bildung\",\"Inneres und Recht\"]", "[\"Bildung\",\"In…
#> $ item_url     <chr> "/gegenstand/XXVIII/SNME/2825", "/gegenstand/XXVIII/SN/10…
#> $ statements   <chr> "0", "0", "0", "0", "56", "0", "0", "0", "0", "0", "2", "…
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
#> $ legis_period <chr> "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", "…
#> $ date         <date> 2019-07-02, 2018-02-28, 2019-02-27, 2019-07-02, 2019-04-…
#> $ active       <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ item_id      <chr> "936/A", "111/A und Zu 111/A", "629/A", "941/A", "780/A",…
#> $ item_code    <chr> "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A…
#> $ item         <chr> "Gesetzesinitiative", "Gesetzesinitiative", "Gesetzesinit…
#> $ title        <chr> "Gehaltskassengesetz, Änderung (936/A)", "Soziale Absiche…
#> $ topic        <chr> "[\"Arbeit\",\"Gesundheit und Ernährung\",\"Wirtschaft\"]…
#> $ item_url     <chr> "/gegenstand/XXVI/A/936", "/gegenstand/XXVI/A/111", "/geg…
#> $ statements   <chr> "0", "0", "0", "0", "0", "6", "0", "0", "0", "0", "0", "0…
#> $ ministry     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…

# Get participation data on all ministerial drafts for legislative periods 26 and 27
result <- get_participation(
  legis_period = c(26, 27),
  item = "ME"
)
dplyr::glimpse(result)
#> Rows: 516
#> Columns: 11
#> $ legis_period <chr> "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", "…
#> $ date         <date> 2019-04-30, 2019-04-04, 2019-04-12, 2019-04-10, 2019-04-…
#> $ active       <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ item_id      <chr> "144/ME", "132/ME", "137/ME", "135/ME", "136/ME", "138/ME…
#> $ item_code    <chr> "ME", "ME", "ME", "ME", "ME", "ME", "ME", "ME", "ME", "ME…
#> $ item         <chr> "Ministerialentwurf", "Ministerialentwurf", "Ministeriale…
#> $ title        <chr> "32. StVO-Novelle, Führerscheingesetz, Änderung (144/ME)"…
#> $ topic        <chr> "[\"Verkehr und Infrastruktur\"]", "[\"Budget und Finanze…
#> $ item_url     <chr> "/gegenstand/XXVI/ME/144", "/gegenstand/XXVI/ME/132", "/g…
#> $ statements   <chr> "39", "35", "21", "21", "38", "27", "20", "27", "101", "2…
#> $ ministry     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…

# Get all ministerial drafts (Ministervorlagen) from legislative period 28
# and their number of submitted statements
get_participation(item = "ME", legis_period = 28) |>
  dplyr::select(
    legis_period, date, item_id, item, title, statements
  )
#> # A tibble: 132 × 6
#>    legis_period date       item_id item               title           statements
#>    <chr>        <date>     <chr>   <chr>              <chr>           <chr>     
#>  1 XXVIII       2025-10-03 56/ME   Ministerialentwurf MinroG-Novelle… 5         
#>  2 XXVIII       2025-02-03 6/ME    Ministerialentwurf Kreditdienstle… 12        
#>  3 XXVIII       2025-07-30 39/ME   Ministerialentwurf IFI-Beitragsge… 5         
#>  4 XXVIII       2026-05-04 101/ME  Ministerialentwurf Unterstützungs… 29        
#>  5 XXVIII       2025-09-15 46/ME   Ministerialentwurf Arbeitsmarktse… 31        
#>  6 XXVIII       2025-09-19 48/ME   Ministerialentwurf EMFG Begleitge… 18        
#>  7 XXVIII       2025-09-19 49/ME   Ministerialentwurf Bundesgesetz ü… 22        
#>  8 XXVIII       2025-10-02 52/ME   Ministerialentwurf Zivilrechtlich… 21        
#>  9 XXVIII       2025-11-03 65/ME   Ministerialentwurf Bundespflegege… 24        
#> 10 XXVIII       2025-10-10 58/ME   Ministerialentwurf Vergaberechtsg… 55        
#> # ℹ 122 more rows

# Get statements submitted on ministerial drafts
result <- get_participation(
  item = "SN",
  statement_type = "SNME"
)
dplyr::glimpse(result)
#> Rows: 100,000
#> Columns: 11
#> $ legis_period <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII…
#> $ date         <date> 2025-10-18, 2025-08-13, 2026-07-02, 2025-10-22, 2026-06-…
#> $ active       <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ item_id      <chr> "319/SN-44/ME", "364/SN-32/ME", "2/SN-125/ME", "489/SN-44…
#> $ item_code    <chr> "SNME", "SNME", "SNME", "SNME", "SN", "SNME", "SNME", "SN…
#> $ item         <chr> "Stellungnahme", "Stellungnahme", "Stellungnahme", "Stell…
#> $ title        <chr> "Bundesgesetz zur Stärkung der Selbstbestimmung von unmün…
#> $ topic        <chr> NA, NA, "[\"Budget und Finanzen\",\"Information und Medie…
#> $ item_url     <chr> "/gegenstand/XXVIII/SNME/2015", "/gegenstand/XXVIII/SNME/…
#> $ statements   <chr> "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0…
#> $ ministry     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…

# Get participation data on legislative initiatives with specific initiative type
result <- get_participation(
  item = "RGES",
  initiative_type = "RV"
)
dplyr::glimpse(result)
#> Rows: 7,797
#> Columns: 11
#> $ legis_period <chr> "IX", "IV", "IX", "IV", "IX", "III", "IV", "IV", "IX", "I…
#> $ date         <date> 1959-12-02, 1930-12-16, 1959-12-02, 1930-12-11, 1959-12-…
#> $ active       <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ item_id      <chr> "106 d.B.", "7 d.B.", "107 d.B.", "3 d.B.", "108 d.B.", "…
#> $ item_code    <chr> "I", "I", "I", "I", "I", "I", "I", "I", "I", "I", "I", "I…
#> $ item         <chr> "Gesetzesinitiative", "Gesetzesinitiative", "Gesetzesinit…
#> $ title        <chr> "Regierungsvorlage: Bundes(verfassungs)gesetz (106 d.B.)"…
#> $ topic        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ item_url     <chr> "/gegenstand/IX/I/106", "/gegenstand/IV/I/7", "/gegenstan…
#> $ statements   <chr> "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0…
#> $ ministry     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
# }
```
