# Get Members of Parliament

`get_mps()` retrieves information about Members of Parliament based on
specified filter criteria. The function mirrors the search functionality
'Parlamentarier:innen ab 1918' *(Parliamentarians since 1918)* from the
Austrian Parliament website
[here](https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918/index.html).

## Usage

``` r
get_mps(
  search_string = NULL,
  institution = NULL,
  gender = "all",
  legis_period = NULL,
  date = NULL,
  party = NULL,
  parl_group = NULL,
  state = NULL,
  electoral_district = NULL,
  presidents_only = NULL,
  echo = TRUE
)
```

## Arguments

- search_string:

  Search string (not only names).

- institution:

  Chamber of Parliament.

  - "NR" (Nationalrat, National Council)

  - "BR" (Bundesrat, Federal Council)

  - "KN" (Konstituierende Nationalversammlung, Constituent National
    Assembly)

  - "PN" (Provisorische Nationalversammlung, Provisional National
    Assembly)

  - NULL covers all institutions.

- gender:

  Gender filter. One of "all", "female", or "male"

- legis_period:

  Legislative period. Can be "all", a numeric value, "PN" (Provisorische
  Nationalversammlung), or "KN" (Konstituierende Nationalversammlung)

- date:

  Date for which active MPs are queried. Must be a single date
  (length 1) in format DD.MM.YYYY.

- party:

  Political party filter. See details for permissible values.

- parl_group:

  Parliamentary group filter

- state:

  State filter. See details for permissible values.

- electoral_district:

  Electoral district filter. See details for permissible values.

- presidents_only:

  Logical. If TRUE, returns only presidents. Default is FALSE

- echo:

  Logical. If `TRUE`, the function prints the used search parameters and
  the url to the pertaining search results on website of the Austrian
  Parliament.

## Value

A dataframe containing information about the MPs. One row per MP.
Important: The API returns details on all MPs who e.g. have been member
of Parliament during the requested legislative period. The details
returned, however, are not limited to the requested period. The column
`parl_group` may also contain data on the MP's membership in a
parliamentary group during the requested period, but also also on his or
her membership in other parliamentary groups in the past.

Columns returned:

- `pad_intern`: Person's unique identification number

- `date`: Requested date (only included when `date` input is provided)

- `name`: Name of the MP

- `gender`: Gender (male, female)

- `parl_group`: Parliamentary group; note that the groups stated
  comprises *all* past and present groups of which the MP has been
  member of

- `parl_group_abbrev`: Abbreviation of the parliamentary group

- `legis_period`: Legislative period(s)

- `mandate_detail`: Details on mandates in Parliament at the queried
  period of time (not all mandates). To obtain all mandates, use
  [`get_mandates()`](https://werkstattcodes.github.io/ParlAT/reference/get_mandates.md).

- `electoral_district`: Electoral district

## Details

### search_string

Specifying `search_string` will filter the results across all columns,
not only names.

### legis_period

Filtering for a legislative period is only possible for the National
Council (Nationalrat), the Constituent National Assembly
(Konstituierende Nationalversammlung), and the Provisional National
Assembly (Provisorische Nationalversammlung). Including a legislative
period argument will exclude any results for the Federal Council
(Bundesrat) since its composition \#' follows different electoral
cycles.

Providing a 'legis_period' input will return one row per unique
combination of MP and legislative period. The list-column 'mp_details'
contains all mandate details for that MP during the specified
legislative period. Since an MP can change within a single legislative
period, for example, family name, party affiliation, parliamentary
group, or the electoral district of her mandate, 'mp_details' may
include multiple rows reflecting these changes.

### parl_group

Permissible values:

- Abgeordnetenverband des Landbundes für Österreich

- Bundesratsfraktion der Großdeutschen Volkspartei

- Bundesratsfraktion der Grünen; Grüne Fraktion im Bundesrat

- Bundesratsfraktion der SPÖ

- Bundesratsfraktion der WdU

- Bundesratsfraktion der ÖVP

- Christlichsoziale Fraktion im Bundesrate

- Christlichsoziale Vereinigung deutscher Abgeordneter

- Christlichsoziale Vereinigung deutscher Abgeordneter im
  österreichischen Parlamente

- Der Grüne Klub

- Der Grüne Klub - Klub der Grün-Alternativen Abgeordneten

- Der Grüne Klub im Parlament - Klub der Grünen Abgeordneten zum
  Nationalrat, Bundesrat und Europäischen Parlament

- Die Sozialdemokratische Parlamentsfraktion - Klub der
  sozialdemokratischen Abgeordneten zum Nationalrat, Bundesrat und
  Europäischen Parlament

- Fraktion der Freiheitlichen Bundesräte; Freiheitliche
  Bundesratsfraktion

- Fraktion der Sozialdemokratischen Bundesratsmitglieder

- Freiheitlicher Parlamentsklub

- Freiheitlicher Parlamentsklub; Freiheitlicher Parlamentsklub - BZÖ

- Großdeutsche Vereinigung

- Großdeutsche Volkspartei

- Klub Liberales Forum

- Klub der Freiheitlichen

- Klub der Freiheitlichen Partei Österreichs

- Klub der Kommunisten und Linkssozialisten

- Klub der Sozialistischen Abgeordneten und Bundesräte

- Klub der Sozialistischen Abgeordneten und Bundesräte;
  Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen
  Abgeordneten und Bundesräte

- Klub der Sozialistischen Partei Österreichs

- Klub der Sozialistischen Partei Österreichs; Klub der Sozialistischen
  Abgeordneten und Bundesräte

- Klub der Unabhängigen; Klub der Wahlpartei der Unabhängigen

- Klub der Wahlpartei der Unabhängigen

- Klub der Österreichischen Volksopposition

- Klub der Österreichischen Volkspartei

- Klub der Österreichischen Volkspartei; Parlamentsklub der
  Österreichischen Volkspartei

- Klub des Linksblocks (Kommunisten und Linkssozialisten)

- Klub von NEOS und LIF; Klub von NEOS

- Klub von NEOS; NEOS Parlamentsklub

- Liste Pilz

- NEOS Parlamentsklub

- Parlamentarischer Klub des Heimatblocks

- Parlamentsklub JETZT

- Parlamentsklub Liberales Forum

- Parlamentsklub Team Stronach

- Parlamentsklub der Kommunistischen Partei Österreichs

- Parlamentsklub der Sozialistischen Partei Österreichs; Klub der
  Sozialistischen Partei Österreichs

- Parlamentsklub der Österreichischen Volkspartei

- Parlamentsklub der Österreichischen Volkspartei; Klub der
  Österreichischen Volkspartei

- Parlamentsklub des BZÖ

- Parlamentsklub des Liberalen Forums

- Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen
  Abgeordneten und Bundesräte

- Sozialdemokratische Vereinigung

- Verband der Abgeordneten der Großdeutschen Volkspartei

- Verband der Abgeordneten des Nationalen Wirtschaftsblocks

- Verband der Sozialdemokratischen Abgeordneten zum Nationalrat

- Verband der Sozialdemokratischen Abgeordneten zum Nationalrat
  Deutschösterreichs

- Verband der Sozialdemokratischen Abgeordneten zum Nationalrat; Verband
  der Sozialdemokratischen Abgeordneten zum Nationalrat
  Deutschösterreichs

- Verband der deutschnationalen Parteien und weitere deutschnationale
  Klubs

- ohne Fraktionszugehörigkeit

- ohne Klubzugehörigkeit

### party

Parties to be searched for. Use abbreviation in parentheses as function
input.

- Bauernpartei (BP)

- Bündnis Zukunft Österreich (BZÖ)

- Bürgerlich-demokratische Partei (BDP)

- Bürgerliche Arbeitspartei (BAP)

- Christlichsoziale Partei (CSP)

- Die Freiheitlichen in Kärnten - BZÖ (BZÖK)

- Die Freiheitlichen in Kärnten - Liste Gerhard Dörfler (FPK)

- Die Grünen (Grüne)

- Freiheitliche Partei Österreichs (FPÖ)

- Großdeutsche Vereinigung (GdP)

- Großdeutsche Volkspartei (GdP)

- Heimatblock (HB)

- Jüdisch-Nationale Partei (JNP)

- Kommunisten und Linkssozialisten (KuL)

- Kommunistische Partei Österreichs (KPÖ)

- Landbund (LBd)

- Liberales Forum (L)

- Linksblock (LB)

- Liste Fritz Dinkhauser - FRITZ (FRITZ)

- Liste Peter Pilz (PILZ)

- NEOS - Das neue Österreich und Liberales Forum (NEOS)

- Nationaler Wirtschaftsblock (NWB)

- Österreichische Volkspartei (ÖVP)

- Sozialdemokratische Arbeiterpartei Deutschösterreichs (SdP)

- Sozialdemokratische Partei Österreichs (SPÖ)

- Sozialistische Partei Österreichs (SPÖ)

- Team Frank Stronach - Frank (STRONA)

- Tschechische Partei (TS)

- Volksopposition (VO)

- Wahlpartei der Unabhängigen (WdU)

- ohne Parteizugehörigkeit (OP)

### electoral_district

Permissible values:

- Bundeswahlvorschlag

- Burgenland

- Burgenland Nord

- Burgenland Süd

- Deutsch-Südtirol

- Flachgau/Tennengau

- Graz

- Graz und Umgebung

- Hausruckviertel

- Innsbruck-Land

- Innviertel

- Klagenfurt

- Kärnten

- Kärnten Ost

- Kärnten West

- Lienz

- Linz und Umgebung

- Lungau/Pinzgau/Pongau

- Mittel- und Untersteier

- Mostviertel

- Mühlviertel

- Niederösterreich

- Niederösterreich Mitte

- Niederösterreich Ost

- Niederösterreich Süd

- Niederösterreich Süd-Ost

- Nordtirol

- Oberland

- Obersteier

- Obersteiermark

- Oberösterreich

- Oststeier

- Oststeiermark

- Reststimmenmandat

- Salzburg

- Salzburg Stadt

- Steiermark

- Steiermark Mitte

- Steiermark Nord

- Steiermark Nord-West

- Steiermark Ost

- Steiermark Süd

- Steiermark Süd-Ost

- Steiermark West

- Thermenregion

- Tirol

- Traunviertel

- Unterland

- Viertel oberm Manhartsberg

- Viertel oberm Wienerwald

- Viertel unterm Manhartsberg

- Viertel unterm Wienerwald

- Villach

- Vorarlberg

- Vorarlberg Nord

- Vorarlberg Süd

- Wahlkreisverband I (Burgenland, Niederösterreich, Wien)

- Wahlkreisverband I (Wien)

- Wahlkreisverband II (K, OÖ, S, St, T u V)

- Wahlkreisverband II (Niederösterreich)

- Wahlkreisverband III (OÖ, S, T u. V)

- Wahlkreisverband III - Oberösterreich

- Wahlkreisverband III - Salzburg

- Wahlkreisverband III - Tirol

- Wahlkreisverband IV (B, K u St.)

- Wahlkreisverband IV - Burgenland

- Wahlkreisverband IV - Kärnten

- Wahlkreisverband IV - Steiermark

- Waldviertel

- Weinviertel

- Weststeiermark

- Wien

- Wien Innen-Ost

- Wien Innen-Süd

- Wien Innen-West

- Wien Nord

- Wien Nord-West

- Wien Nordost

- Wien Nordwest

- Wien Süd

- Wien Süd-West

- Wien Südost

- Wien Südwest

- Wien Umgebung

- Wien West

### state

Permissible values:

- Bundeswahlvorschlag

- Burgenland

- Kärnten

- Niederösterreich

- Oberösterreich

- Salzburg

- Steiermark

- Tirol

- Vorarlberg

- Wien

## Examples

``` r
# \donttest{
# Get all MPs from the current legislative period
mps <- get_mps(institution = "NR", legis_period = "27")
#> {"ATTR_JSON.mandate_detail.gremium_name":["Nationalrat"],"ATTR_JSON.mandate_detail.gp_text_full_short":["23.10.2019 - 23.10.2024: XXVII. GP"]} 
#> https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918?PERSON_409ATTR_JSON.mandate_detail.gremium_name=Nationalrat&PERSON_409ATTR_JSON.mandate_detail.gp_text_full_short=23.10.2019%20-%2023.10.2024:%20XXVII.%20GP
#> [1] 213

# Get female MPs from a specific party
female_mps <- get_mps(gender = "female", party = "SPÖ")
#> {"GESCHL_CODE":["W"],"ATTR_JSON.mandate_detail.wahlpartei_full_txt":["Sozialdemokratische Partei Österreichs (SPÖ)","Sozialistische Partei Österreichs (SPÖ)"]} 
#> https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918?PERSON_409GESCHL_CODE=W&PERSON_409ATTR_JSON.mandate_detail.wahlpartei_full_txt=Sozialdemokratische%20Partei%20%C3%96sterreichs%20(SP%C3%96)&PERSON_409ATTR_JSON.mandate_detail.wahlpartei_full_txt=Sozialistische%20Partei%20%C3%96sterreichs%20(SP%C3%96)
#> [1] 211
# }
```
