# Get detailed stage information for a parliamentary item

**\[experimental\]**

## Usage

``` r
get_item_details(item_url, stages = TRUE, votes = TRUE)
```

## Arguments

- item_url:

  Character. A single URL or path to an item on the Austrian Parliament
  website. Can be an absolute URL starting with
  "https://www.parlament.gv.at/" or a relative path (with or without
  leading slashes). The function will normalize relative paths
  automatically.

- stages:

  Logical. If `TRUE` (default), extract stage information and add it as
  the `stages` list-column. If `FALSE`, return only item-level metadata.

- votes:

  Logical. If `TRUE` (default), add vote information from `content$vote`
  as the `votes` list-column for items of the National Council. If
  `FALSE`, omit vote information.

## Value

A one-row tibble containing detailed information about the parliamentary
item. If `stages = TRUE`, the result contains a `stages` list-column
with stage information, or `NULL` if the item has no stages yet. Emits a
warning if the page structure is unrecognised (possible API change).

**Item-level columns:**

- `item_url` (character): The URL of the parliamentary item.

- `item_type` (character): Raw item type code from `ityp`.

- `type_doc` (character): Raw document type code from `doktyp`.

- `type_doc_long` (character): Human-readable document type.

- `title` (character): The title of the item.

- `item_number` (character): The citation number (e.g. "61/A").

- `item_description` (character): A brief description of the item.

- `state_statements` (character): Statement stage information.

- `state_approval` (character): The current approval state.

- `date_introduced` (Date): The date the item was introduced to
  parliament.

- `legis_period` (character): Legislative period code (e.g. "XXVII").

- `status_number` (integer): Current status number.

- `status_description` (character): Current status description (HTML
  stripped).

- `item_documents` (list): Tibble with columns `doc_title`, `link`,
  `type` for item-level documents. `NULL` if none.

- `introducers` (list): Tibble with columns `role`, `name`, `frak_code`,
  `url` for the persons who introduced the item. `NULL` if unavailable.

- `references` (list): Tibble with columns `text`, `subject`,
  `zitation`, `url`, `art` for related parliamentary items. `NULL` if
  none.

- `topics` (list): Character vector of topic labels.

- `headwords` (list): Character vector of headword labels.

- `eurovoc` (list): Character vector of EuroVoc terms.

- `votes` (list): Vote information from the item page for items of the
  National Council. `NULL` if none.

**Stage-level columns** (inside `stages`):

- `phase` (character): The phase of the legislative stage (e.g.
  "Ausschussbehandlung"). `NA` for items with flat stages (no phase
  wrapper).

- `stage_date` (Date): The date of the stage.

- `stage_name` (character): The name/description of the stage (HTML
  stripped).

- `stage_names` (list): Stage-level names/introducer information, if
  present.

- `speeches` (list): Nested tibble with columns `speaker`,
  `speaker_url`, `position`, `protocol_page`, `protocol_url`,
  `video_url`. `NULL` for stages without debate contributions.

## Details

Retrieves detailed stage information for a specific parliamentary item
by scraping its detail page on the Austrian Parliament website. The
function extracts structured data about the item's progression through
different legislative stages.

The function performs the following steps:

1.  Normalizes the URL (prepends "https://www.parlament.gv.at/" if
    needed)

2.  Scrapes the item's detail page

3.  Extracts structured data from embedded JavaScript

4.  Parses HTML content within stage text fields

5.  Returns a one-row tibble with item metadata and optional stage
    details

## See also

- [`get_items()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_items.md)
  for searching parliamentary items and retrieving URLs

## Examples

``` r
# \donttest{
# Get details for a specific item
item_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"
details <- get_item_details(item_url)
dplyr::glimpse(details)
#> Rows: 1
#> Columns: 21
#> $ item_url           <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/BI/2…
#> $ item_type          <chr> "BI"
#> $ type_doc           <chr> "BI"
#> $ type_doc_long      <chr> "Bürgerinitiative"
#> $ title              <chr> "Neutralität Österreichs sichern!"
#> $ item_number        <chr> "24/BI"
#> $ item_description   <chr> "Bürgerinitiative betreffend \"Neutralität Österrei…
#> $ state_statements   <chr> "1"
#> $ state_approval     <chr> "1"
#> $ date_introduced    <date> 2025-08-20
#> $ legis_period       <chr> "XXVIII"
#> $ status_number      <int> 3
#> $ status_description <chr> "Ausschuss für Petitionen und Bürgerinitiativen: au…
#> $ item_documents     <list> [<tbl_df[1 x 3]>]
#> $ introducers        <list> [<tbl_df[1 x 4]>]
#> $ references         <list> <NULL>
#> $ topics             <list> <"Außenpolitik", "Europäische Union", "Information …
#> $ headwords          <list> <"Bürgerinitiativen", "Außenpolitik", "Europäische …
#> $ eurovoc            <list> <"Europäische Union", "Handel", "Industrie", "Infor…
#> $ votes              <list> <NULL>
#> $ stages             <list> [<tbl_df[13 x 3]>]

# Also works with relative paths
details <- get_item_details("/gegenstand/XXVIII/BI/24")
dplyr::glimpse(details)
#> Rows: 1
#> Columns: 21
#> $ item_url           <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/BI/2…
#> $ item_type          <chr> "BI"
#> $ type_doc           <chr> "BI"
#> $ type_doc_long      <chr> "Bürgerinitiative"
#> $ title              <chr> "Neutralität Österreichs sichern!"
#> $ item_number        <chr> "24/BI"
#> $ item_description   <chr> "Bürgerinitiative betreffend \"Neutralität Österrei…
#> $ state_statements   <chr> "1"
#> $ state_approval     <chr> "1"
#> $ date_introduced    <date> 2025-08-20
#> $ legis_period       <chr> "XXVIII"
#> $ status_number      <int> 3
#> $ status_description <chr> "Ausschuss für Petitionen und Bürgerinitiativen: au…
#> $ item_documents     <list> [<tbl_df[1 x 3]>]
#> $ introducers        <list> [<tbl_df[1 x 4]>]
#> $ references         <list> <NULL>
#> $ topics             <list> <"Außenpolitik", "Europäische Union", "Information …
#> $ headwords          <list> <"Bürgerinitiativen", "Außenpolitik", "Europäische …
#> $ eurovoc            <list> <"Europäische Union", "Handel", "Industrie", "Infor…
#> $ votes              <list> <NULL>
#> $ stages             <list> [<tbl_df[13 x 3]>]
# }
```
