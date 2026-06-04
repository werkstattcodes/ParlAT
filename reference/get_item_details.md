# Get detailed information for a parliamentary item ('Verhandlungsgegenstand')

**\[experimental\]**

Returns detailed information for a specific parliamentary item
('Verhandlungsgegenstand') by retrieving data from its detail page on
the Austrian Parliament website. The function returns item-level
metadata and, optionally, structured information about legislative
stages and votes.

## Usage

``` r
get_item_details(item_url, stages = TRUE, votes = TRUE)
```

## Arguments

- item_url:

  Character. A single URL or path to an item ('Verhandlungsgegenstand')
  on the Austrian Parliament website. Can be an absolute URL starting
  with "https://www.parlament.gv.at/" or a relative path (with or
  without leading slashes). The function will normalize relative paths
  automatically. URLs are best obtained via a preceding call with
  [`get_items()`](https://werkstattcodes.github.io/ParlAT/reference/get_items.md).

- stages:

  Logical. If `TRUE` (default), extract stage information and add it as
  the `stages` list-column. If `FALSE`, return only item-level metadata.

- votes:

  Logical. If `TRUE` (default), add vote information from the item page
  as the `votes` list-column. \*Returns only data for votes on items
  under consideration in the third reading ('dritte Lesung') in the
  National Council. If `FALSE`, omits vote extraction and the `votes`
  column.

## Value

A one-row tibble containing detailed information about the parliamentary
item. The `stages` list-column is included only when `stages = TRUE`; it
contains stage information, or `NULL` if the item has no stages yet. The
`votes` list-column is included only when `votes = TRUE`; Emits a
warning if the page structure is unrecognised.

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

- `votes` (list): Vote information from the item page. `votes[[1]]` is
  either `NULL` or a list with fields `result`, `infavor`, `code`,
  `text`, and `comment`. The nested `result` field is a data frame with
  columns `text`, `code`, `color`, `fraction`, and `infavor`.

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

## See also

- [`get_items()`](https://werkstattcodes.github.io/ParlAT/reference/get_items.md)
  for searching parliamentary items and retrieving URLs

## Examples

``` r
# \donttest{
# Get details for a specific item with vote information
item_url <- "https://www.parlament.gv.at/gegenstand/XX/I/1833"
details <- get_item_details(item_url, stages = FALSE)
dplyr::glimpse(details)
#> Rows: 1
#> Columns: 20
#> $ item_url           <chr> "https://www.parlament.gv.at/gegenstand/XX/I/1833"
#> $ item_type          <chr> "I"
#> $ type_doc           <chr> "RV"
#> $ type_doc_long      <chr> "Regierungsvorlage: Bundes(verfassungs)gesetz"
#> $ title              <chr> "Gefahrgutbeförderungsgesetz, Änderung"
#> $ item_number        <chr> "1833 d.B."
#> $ item_description   <chr> "Bundesgesetz, mit dem das Gefahrgutbeförderungsges…
#> $ state_statements   <chr> "0"
#> $ state_approval     <chr> "9 Keine Zustimmung bei dem Doktyp \"RV\" möglich"
#> $ date_introduced    <date> 1999-05-17
#> $ legis_period       <chr> "XX"
#> $ status_number      <int> 5
#> $ status_description <chr> "Kein Einspruch\n174. Sitzung des Nationalrates: Ge…
#> $ item_documents     <list> [<tbl_df[2 x 3]>]
#> $ introducers        <list> <NULL>
#> $ references         <list> [<tbl_df[1 x 5]>]
#> $ topics             <list> "Verkehr und Infrastruktur"
#> $ headwords          <list> "Verkehr V. Sonstiges"
#> $ eurovoc            <list> "Verkehr"
#> $ votes              <list> [[<data.frame[5 x 5]>], TRUE, "SVflg", "Dafür: S, V…
details$votes[[1]]
#> $result
#>    text code   color fraction infavor
#> 1   SPÖ    S #FF0000       71    TRUE
#> 2   ÖVP    V #000000       52    TRUE
#> 3     F    F #0052FB       41   FALSE
#> 4     L    L #B0D8F3        9   FALSE
#> 5 GRÜNE    G #69B12E        9   FALSE
#> 
#> $infavor
#> [1] TRUE
#> 
#> $code
#> [1] "SVflg"
#> 
#> $text
#> [1] "Dafür: S, V. Dagegen: F, L, G"
#> 
#> $comment
#> NULL
#> 
details$votes[[1]]$result
#>    text code   color fraction infavor
#> 1   SPÖ    S #FF0000       71    TRUE
#> 2   ÖVP    V #000000       52    TRUE
#> 3     F    F #0052FB       41   FALSE
#> 4     L    L #B0D8F3        9   FALSE
#> 5 GRÜNE    G #69B12E        9   FALSE

# Also works with relative paths
details <- get_item_details("/gegenstand/XX/I/1833", stages = FALSE)
dplyr::glimpse(details)
#> Rows: 1
#> Columns: 20
#> $ item_url           <chr> "https://www.parlament.gv.at/gegenstand/XX/I/1833"
#> $ item_type          <chr> "I"
#> $ type_doc           <chr> "RV"
#> $ type_doc_long      <chr> "Regierungsvorlage: Bundes(verfassungs)gesetz"
#> $ title              <chr> "Gefahrgutbeförderungsgesetz, Änderung"
#> $ item_number        <chr> "1833 d.B."
#> $ item_description   <chr> "Bundesgesetz, mit dem das Gefahrgutbeförderungsges…
#> $ state_statements   <chr> "0"
#> $ state_approval     <chr> "9 Keine Zustimmung bei dem Doktyp \"RV\" möglich"
#> $ date_introduced    <date> 1999-05-17
#> $ legis_period       <chr> "XX"
#> $ status_number      <int> 5
#> $ status_description <chr> "Kein Einspruch\n174. Sitzung des Nationalrates: Ge…
#> $ item_documents     <list> [<tbl_df[2 x 3]>]
#> $ introducers        <list> <NULL>
#> $ references         <list> [<tbl_df[1 x 5]>]
#> $ topics             <list> "Verkehr und Infrastruktur"
#> $ headwords          <list> "Verkehr V. Sonstiges"
#> $ eurovoc            <list> "Verkehr"
#> $ votes              <list> [[<data.frame[5 x 5]>], TRUE, "SVflg", "Dafür: S, V…
# }
```
