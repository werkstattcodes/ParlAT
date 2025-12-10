# Get Data on Plenary Sessions of the Austrian Parliament

Retrieves information about plenary sessions from the Austrian
Parliament's API (see
[here](https://www.parlament.gv.at/recherchieren/plenarsitzungen/index.html)).
Data available from 20th legislative period onwards.

## Usage

``` r
get_plenary_sessions(
  institution = NULL,
  legis_period = NULL,
  session_and_activities = NULL,
  submitted = NULL,
  held = NULL,
  echo = FALSE
)
```

## Arguments

- institution:

  A character string specifying the institution. "BR" (Bundesrat/Federal
  Council), "NR" (Nationalrat/National Council), or "BV"
  (Bundesversammlung/Federal Assembly).

- legis_period:

  Numeric value or vector specifying the legislative period(s). Can also
  be NULL to retrieve all periods from 20th onwards. **Must be NULL when
  institution is "BV"** (Bundesversammlung does not use legislative
  periods).

- session_and_activities:

  A character string. One of 'sessions', 'submitted', or 'held'. Not
  applicable when institution is "BV" (Bundesversammlung); must be NULL
  for BV institution.

- submitted:

  A character string specifying the type of submissions that were
  introduced. Possible values are: 'All', 'AA', 'G037', 'G080', 'J',
  'AE', 'G015', 'G014', 'AB', 'G053', 'UEA', 'UEAM'. Only used when
  `session_and_activities = "submitted"`. Not applicable for BV
  institution. See details below.

- held:

  A character string specifying the type of sessions that were held.
  Possible values are: 'All', 'ASEU', 'AS', 'GO04', 'FS', 'RGER',
  'RGEU', 'GO', 'GO35'. Only used when
  `session_and_activities = "held"`. Not applicable for BV institution.
  See details below.

- echo:

  Logical. If `TRUE`, prints the API request body parameters and the
  number of results. Default is `FALSE`.

## Value

A data frame containing plenary session details, or NULL if no results
found. The structure depends on `session_and_activities` parameter:

If *`session_and_activities = "sessions"`*:

- `institution`: parliamentary institution (e.g., "NR", "BR")

- `legis_period`: legislative period (not returned if institution is
  'BV')

- `date`: date of the session

- `session_number`: number of the session

- `session_day`: day of session

- `session_url`: URL to the session page

- `agenda_url_html`: URL to the agenda in HTML format

- `agenda_url_pdf`: URL to the agenda in PDF format

If *`session_and_activities = "submitted"` or `"held"`*:

- `legis_period`: legislative period

- `date`: date of the activity

- `url_session_item`: URL to the session item

- `url_session`: URL to the session

- `type_title`: title of the activity type

- `type_txt`: text of the activity type

- `topic`: topic of the activity

- `citation`: item citation

- `session_number`: number of session

- `session_type_abbrev`: abbreviation for the session type

- `session_type_name`: full name of session type

- `link`, `link_2`, `link_3`: Additional links related to the activity

For *BV (Bundesversammlung) institution*:

- Returns basic session information without the activity-specific
  filtering options available for BR/NR

- Does NOT include `legis_period` column (not applicable for Federal
  Assembly)

- Columns returned: `institution`, `date`, `session_number`,
  `session_day`, `session_url`, `agenda_url_html`, `agenda_url_pdf`

## Details

The function argument `session_and_activities` allows for three
different inputs: `sessions`: Returns details on the plenary sessions
held. `submitted`: Returns details on the submissions made during the
plenary sessions. `held`: Returns details on the type of sessions held
during the plenary sessions.

Possible values for `submitted` if `session_and_activities` is set to
`submitted`:

- All

- AA: Abänderungsanträge (Amendment Motions)

- G037: Anträge auf Absetzung von der Tagesordnung (Motions to Remove
  from Agenda)

- G080: Anträge auf Durchführung einer Volksabstimmung (Motions for
  Referendum)

- J: Dringliche Anfragen (Urgent Inquiries)

- AE: Dringliche Anträge (Urgent Motions)

- G015: Fristerstreckungsanträge (Deadline Extension Motions)

- G014: Fristsetzungsanträge (Deadline Setting Motions)

- AB: Kurze Debatten über Anfragebeantwortungen (Brief Debates on
  Inquiry Responses)

- G053: Rückverweisungsanträge (Referral Back Motions)

- UEA: Unselbständige Entschließungsanträge (Dependent Resolution
  Motions)

- UEAM: Unselbständige Misstrauensanträge (Dependent No-Confidence
  Motions)

Possible values for `held` if `session_and_activities` is set to `held`:

- All

- ASEU: Aktuelle Europastunden (Current Europe Hours)

- AS: Aktuelle Stunden (Current Hours)

- GO04: Erklärungen des Präsidenten / der Präsidentin (President
  Declarations)

- FS: Fragestunden (Question Hours)

- RGER: Regierungserklärungen (Government Declarations)

- RGEU: Regierungserklärungen zu EU-Themen (Government Declarations on
  EU Topics)

- GO: Sonstige Geschäftsordnungsangelegenheiten (Other Procedural
  Matters)

- GO35: Unterrichtungen gemäß Art. 50 Abs. 5 B-VG (Notifications
  according to Art. 50 Para. 5 B-VG)

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage: Get sessions for National Council, legislative periods 20-27
sessions_20_27 <- get_plenary_sessions(
  institution = "NR",
  legis_period = seq(20, 27),
  session_and_activities = "sessions",
  echo = TRUE
)

# Get activities submitted during sessions
get_plenary_sessions(
  institution = "NR",
  legis_period = 27,
  session_and_activities = "submitted"
)

# Get specific type of submitted activities (urgent inquiries)
get_plenary_sessions(
  institution = "NR",
  legis_period = 27,
  session_and_activities = "submitted",
  submitted = "J"
)

# Get activities held during sessions
get_plenary_sessions(
  institution = "NR",
  legis_period = 27,
  session_and_activities = "held",
  held = "FS"
)

# Federal Council sessions
get_plenary_sessions(
  institution = "BR",
  legis_period = 28,
  session_and_activities = "sessions"
)

# Multiple legislative periods
get_plenary_sessions(
  institution = "NR",
  legis_period = c(26, 27),
  session_and_activities = "sessions"
)

# All periods from 20th onwards (NULL legis_period)
get_plenary_sessions(
  institution = "NR",
  legis_period = NULL,
  session_and_activities = "sessions"
)
} # }
```
