# Get colors for Austrian political parties

`get_party_colors()` returns a named vector or tibble of colors for
Austrian political parties and parliamentary groups. It accepts common
party codes, short parliamentary abbreviations, and full party or
parliamentary group names.

## Usage

``` r
get_party_colors(
  parties = NULL,
  legis_period = NULL,
  output = c("vector", "tibble"),
  unmatched = c("NA", "error")
)
```

## Arguments

- parties:

  Character vector of party or parliamentary group names, abbreviations,
  or codes. If `NULL`, returns the default plotting palette.

- legis_period:

  Optional legislative period. If supplied, the historical color for the
  Austrian People's Party (`"ÖVP"`) is returned as `"black"` before
  legislative period 26 and as the modern palette color from period 26
  onward. May be length 1 or the same length as `parties`.

- output:

  Character string. `"vector"` returns a named character vector;
  `"tibble"` returns a tibble with party names and colors.

- unmatched:

  Character string. `"NA"` returns `NA` for unmatched inputs; `"error"`
  throws an error if any input cannot be matched.

## Value

A named character vector by default. With `output = "tibble"`, a tibble
with columns `party`, `canonical_party`, and `color`.

## Examples

``` r
get_party_colors()
#>         SPÖ         ÖVP         FPÖ           F       F-BZÖ       GRÜNE 
#>   "#CE000C"   "#63C3D0"   "#0056A2"   "#0056A2"   "#0056A2"   "#88B626" 
#>        NEOS    NEOS-LIF    STRONACH         BZÖ         LIF           L 
#>   "#E3257B"   "#E3257B"   "#F47100"   "#F47100"   "#FFD200"   "#FFD200" 
#>       FRANK       JETZT        PILZ          OK          OF 
#>   "#F47100" "lightgrey" "lightgrey"      "grey"      "grey" 
get_party_colors(c("SPÖ", "ÖVP", "FPÖ"))
#>       SPÖ       ÖVP       FPÖ 
#> "#CE000C" "#63C3D0" "#0056A2" 
get_party_colors(c("S", "V", "F"))
#>         S         V         F 
#> "#CE000C" "#63C3D0" "#0056A2" 
get_party_colors(c("ÖVP", "ÖVP"), legis_period = c(25, 26))
#>       ÖVP       ÖVP 
#>   "black" "#63C3D0" 

party_colors <- get_party_colors(output = "tibble")
old_par <- par(no.readonly = TRUE)
par(mar = c(1, 7, 1, 1))
party_colors <- party_colors[nrow(party_colors):1, ]
barplot(
  rep(1, nrow(party_colors)),
  col = party_colors$color,
  names.arg = party_colors$party,
  horiz = TRUE,
  las = 1,
  border = NA,
  axes = FALSE
)


oevp_colors <- get_party_colors(
  c("ÖVP", "ÖVP"),
  legis_period = c(25, 26),
  output = "tibble"
)
oevp_colors <- oevp_colors[nrow(oevp_colors):1, ]
barplot(
  rep(1, nrow(oevp_colors)),
  col = oevp_colors$color,
  names.arg = c("Before GP 26", "From GP 26"),
  horiz = TRUE,
  las = 1,
  border = NA,
  axes = FALSE
)

par(old_par)
```
