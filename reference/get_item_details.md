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
and its stages. Returns `NULL` if no stages are found.

- `item_url` (character): The URL of the parliamentary item.

- `type` (character): The type of the item (e.g., BI for
  Bürgerinitiativen).

- `title` (character): The title of the item.

- `item_number` (character): The citation number of the item.

- `item_description` (character): A brief description of the item.

- `state_approval` (character): The current approval state of the item.

- `phase` (character): The phase of the legislative stage.

- `id` (character): Unique identifier for the stage.

- `stage_date` (Date): The date of the stage.

- `stage_name` (character): The name/description of the stage.

- `stage_priority` (numeric): Priority of the stage.

- `documents` (list): List-column of associated documents for the stage.

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

- [`get_items()`](https://werkstattcodes.github.io/ParlAT/reference/get_items.md)
  for searching parliamentary items and retrieving URLs

## Examples

``` r
if (FALSE) { # \dontrun{
# Get details for a specific item
item_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"
stages <- get_item_details(item_url)

# Also works with relative paths
stages <- get_item_details("/gegenstand/XXVIII/BI/24")
} # }
```
