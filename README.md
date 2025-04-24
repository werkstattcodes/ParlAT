
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ParlAT: Accessing Open Data of the Austrian Parliament

<!-- badges: start -->
<!-- badges: end -->
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Overview

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public..](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

The ParlAT package seeks to provide an easy way for R users to access
the Open Data offered by the Austrian Parliament. This includes, but is
not limited to, data on past and current MPs, plenary sessions, or
transcripts. For an introductory overview and some examples, please see
the “Get started” section. For details, consult the functions’
documentation under “References”.

Please note that the package is under active development. So until it
has reached a mature state, upcoming changes may break existing code.

Also note that neither the package nor its author is affiliated to the
Austrian Parliament.

## Installation

You can install the development version of ParlAT from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("werkstattcodes/ParlAT")
```

## The Open Data Offer of the Austrian Parliament

The Open Data offer of the Austrian Parliament comprises <a
href="https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/index.html"
target="_blank">25 datasets</a> which are made available - with some
exceptions - under a CC BY 4.0 license. These datasets are accessible
via the search interface of the Austrian Parliament website as well as
by directly querying the Parliament’s API. ParlAT seeks to facilitate
accessing the latter.

Mirroring the structure of the API, some of ParlAT’s functions cover
more than one dataset. Other functions are specific to a single dataset.
In addition, ParlAT offers several utility functions which either render
the raw output provided by Parliament’s API more amenable for further
processing or return results which are likely to be of interest for the
user but are not directly returned by the API (see
[references](#references) for details).

### Datasets and pertaining functions by ParlAT

Below a raw tabuliation of the Parliament’s 25 open datasets and the
ParlAT’s pertaining function to access it. Please note that this is only
subset of the available parameters. For details see the function
documentation in the reference section.

| Dataset | ParlAT Function |
|----|----|
| Anträge (Motions) | `get_items(item="ANTR")` |
| Ausschussberichte (Committee reports) | `get_items(item="AUB")` |
| Beschlüsse (Decisions) | `get_items(item="BNR")` |
| Gesetzesanträge des Bundesrates (Legislative Proposals of the Federal Council) | `get_items(item="GABR")` |
| Regierungsvorlagen (Government Bills) | `get_items(item="RV")` |
| Aktuelle Beiligungen (Current calls for public participation) | `get_participation(active="J")` |
| Bürgerinitiativen (Citizen Initiatives) | `get_items(item="BI")` |
| Petitionen (Petitions) | `get_items(item="PET")` |
| Stenographisches Protokolle (Session transcripts) | `get_transcripts()` |
| Plenarsitzungen (Plenary sessions) | `get_plenary_sessions()` |
| Parlamentarier seit 1918 (MPs since 1918) | `get_mps()` |
| Aktuelle Abg. z NR (Current members of National Council) | `get_mps_current(institution="Nationalrat")` |
| Aktuelle Abg. z BR (Current members of National Council) | `get_mps_current(institution="Bundesrat")` |
| Parlamentskorrespondenz (Corrspondance) | not yet implemented |
| Termine (Events) | `get_events()` |
| Ausschüsse (Committees) | `get_committees()` |
| Ausschussmitgliedschaften (Committee membership) | not yet implemented |
| Schriftliche Anfragen NR (Written questions National Council) | `get_items(item="J_JPR_M", institution="Nationalrat")` |
| Schriftliche Anfragen BR (Written questions Federal Council) | `get_items(item="J_JPR_M", institution="Bundesrat")` |
| Stellungnahmen im EU-Hauptausschusses (Statements of the EU Main Committee) | not yet implemented |
| Mitteilungen des EU-Unterausschusses (Communications of the EU Subcommittee) | not yet implemented |
| Stellungnahmen des Ständigen Unterausschusses des Hauptausschusses (Statements of the Permanent Subcommittee of the Main Committee) | `get_proceedings()` |
| Begründete Stellungnahmen des EU-Ausschusses () | not yet implemented |
| Mitteilungen des EU-Ausschusses BR (Communications of the EU Subcommittee - Federal Council) | not yet implemented |
| Stellungnahmen des EU-Ausschusses BR (Statements of the EU Committee Federal Council) | not yet implemented |

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

## References

<!--  -->
