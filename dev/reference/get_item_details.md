# Get detailed stage information for a parliamentary item

**\[experimental\]**

## Usage

``` r
get_item_details(item_url, type = "stages")
```

## Arguments

- item_url:

  Character. A single URL or path to an item on the Austrian Parliament
  website. Can be an absolute URL starting with
  "https://www.parlament.gv.at/" or a relative path (with or without
  leading slashes). The function will normalize relative paths
  automatically.

- type:

  Character. Type of data to extract. Currently only "stages" is
  supported (default).

## Value

A tibble containing detailed information about the parliamentary item
and its stages. Returns `NULL` if the item has no stages yet. Emits a
warning if the page structure is unrecognised (possible API change).

**Item-level columns** (replicated for each stage row):

- `item_url` (character): The URL of the parliamentary item.

- `type` (character): The type of the item (e.g., BI, A, UEA).

- `title` (character): The title of the item.

- `item_number` (character): The citation number (e.g. "61/A").

- `item_description` (character): A brief description of the item.

- `state_statements` (character): Statement stage information.

- `state_approval` (character): The current approval state.

- `date_introduced` (Date): The date the item was introduced to
  parliament.

- `gp_code` (character): Legislative period code (e.g. "XXVII").

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

**Stage-level columns:**

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

5.  Returns a tibble with stage information

## See also

- [`get_items()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_items.md)
  for searching parliamentary items and retrieving URLs

## Examples

``` r
# \donttest{
# Get details for a specific item
item_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"
stages <- get_item_details(item_url)
dplyr::glimpse(stages)
#> Rows: 9
#> Columns: 19
#> $ title              <chr> "Neutralität Österreichs sichern!", "Neutralität Ös…
#> $ item_number        <chr> "24/BI", "24/BI", "24/BI", "24/BI", "24/BI", "24/BI…
#> $ stage_date         <chr> "20.08.2025", "21.08.2025", "22.08.2025", "24.09.20…
#> $ stage_name         <chr> "Einlangen im Nationalrat", "Vorgesehen für den Aus…
#> $ phase              <chr> "Einlangen NR", "Einlangen NR", "Ausschussberatunge…
#> $ item_url           <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/BI/2…
#> $ type               <chr> "Bürgerinitiative", "Bürgerinitiative", "Bürgerinit…
#> $ item_description   <chr> "Bürgerinitiative betreffend \"Neutralität Österrei…
#> $ state_approval     <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1"
#> $ date_introduced    <date> 2025-08-20, 2025-08-20, 2025-08-20, 2025-08-20, 202…
#> $ gp_code            <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", …
#> $ status_number      <int> 3, 3, 3, 3, 3, 3, 3, 3, 3
#> $ status_description <chr> "Ausschuss für Petitionen und Bürgerinitiativen: au…
#> $ item_documents     <list> [<data.frame[1 x 3]>], [<data.frame[1 x 3]>], [<dat…
#> $ introducers        <list> [<tbl_df[0 x 4]>], [<tbl_df[0 x 4]>], [<tbl_df[0 x …
#> $ references         <list> <NULL>, <NULL>, <NULL>, <NULL>, <NULL>, <NULL>, <N…
#> $ topics             <list> <"Außenpolitik", "Europäische Union", "Information…
#> $ headwords          <list> <"Bürgerinitiativen", "Außenpolitik", "Europäische…
#> $ eurovoc            <list> <"Europäische Union", "Handel", "Industrie", "Info…

# Also works with relative paths
stages <- get_item_details("/gegenstand/XXVIII/BI/24")
dplyr::glimpse(stages)
#> Rows: 9
#> Columns: 19
#> $ title              <chr> "Neutralität Österreichs sichern!", "Neutralität Ös…
#> $ item_number        <chr> "24/BI", "24/BI", "24/BI", "24/BI", "24/BI", "24/BI…
#> $ stage_date         <chr> "20.08.2025", "21.08.2025", "22.08.2025", "24.09.20…
#> $ stage_name         <chr> "Einlangen im Nationalrat", "Vorgesehen für den Aus…
#> $ phase              <chr> "Einlangen NR", "Einlangen NR", "Ausschussberatunge…
#> $ item_url           <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/BI/2…
#> $ type               <chr> "Bürgerinitiative", "Bürgerinitiative", "Bürgerinit…
#> $ item_description   <chr> "Bürgerinitiative betreffend \"Neutralität Österrei…
#> $ state_approval     <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1"
#> $ date_introduced    <date> 2025-08-20, 2025-08-20, 2025-08-20, 2025-08-20, 202…
#> $ gp_code            <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", …
#> $ status_number      <int> 3, 3, 3, 3, 3, 3, 3, 3, 3
#> $ status_description <chr> "Ausschuss für Petitionen und Bürgerinitiativen: au…
#> $ item_documents     <list> [<data.frame[1 x 3]>], [<data.frame[1 x 3]>], [<dat…
#> $ introducers        <list> [<tbl_df[0 x 4]>], [<tbl_df[0 x 4]>], [<tbl_df[0 x …
#> $ references         <list> <NULL>, <NULL>, <NULL>, <NULL>, <NULL>, <NULL>, <N…
#> $ topics             <list> <"Außenpolitik", "Europäische Union", "Information…
#> $ headwords          <list> <"Bürgerinitiativen", "Außenpolitik", "Europäische…
#> $ eurovoc            <list> <"Europäische Union", "Handel", "Industrie", "Info…
# }
```
