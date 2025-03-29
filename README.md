
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ParlAT: Accessing Open Data of the Austrian Parliament

<!-- badges: start -->
<!-- badges: end -->
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Overview

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

The ParlAT package seeks to provide an easy way for R users to access
the Open Data offered by the Austrian Parliament. This includes, but is
not limited to, data on past and current MPs, plenary sessions, or
protocols. For an introductory overview and some examples, please see
the “Get started” section. For details, consult the functions’
documentation under “References”.

Please note that the package is under active development. So until it
has reached a mature state, upcoming changes may break existing code.

Also not that this package is in no way affiliated to the Austrian
Parliament. It simply wraps its API and contributes additional utitiliy
functions.

## Installation

You can install the development version of ParlAT from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("werkstattcodes/ParlAT")
```

## The Open Data Offer of the Austrian Parliament

The Open Data offer of the Austrian Parliament comprises 25 datasets
which are made available - with some exceptions- under a CC BY 4.0
license. Each of these data sets by one of ParlAT’s functions. Some
functions are specific to one single dataset, some functions cover more
than a single dataset and differentiate their scope by their
parameters.In addition, the packages includes several utility functions
which render the raw output provided by API more amendable for further
processing (see [references()](#references) for details).

### Datasets and pertaining functions by ParlAT

| Dataset | Main function |  |
|----|----|----|
| Anträge (Motions) | `get_items()` |  |
| Ausschussberichte (Committee reports) | `get_items()` |  |
| Ausschüsse |  |  |
| Ausschussmitgliedschaften |  |  |
| Schriftliche Anfragen NR |  |  |
| Schriftliche Anfragen BR |  |  |
| Stellungnahmen im EU-Hauptausschusses |  |  |
| Mitteilungen des EU-Unterausschusses |  |  |
| Stellungnahmen des Ständigen Unterausschusses des Hauptausschusses(EU) |  |  |
| Begründete Stellungnahmen des EU-Ausschusses (BR) | `get_items()` |  |
| Mitteilungen des EU-Ausschusses BR | `get_items()` |  |
| Stellungnahmen des EU-Ausschusses BR | `get_items()` |  |
| Beschlüsse (Decisions) | `get_items()` |  |
| Gesetzesanträge des Bundesrates () | `get_items()` |  |
| Regierungsvorlagen () | `get_items()` |  |
| Regierungsvorlagen () | `get_items()` |  |
| Aktuelle Beiligungen | `get_participation()    |     | | Bürgerinitiativen                                                     |`get_items()`|     | | Petitionen                                                            |`get_items()`|     | | Parlamentarier seit 1918 (MPs since 1918)                             |`get_mps()`|             | | Aktuelle Abg. z NR (current members of National Council)              |`get_mps_current()`|             | | Aktuelle Abg. z BR (current members of National Council)              |`get_mps_current()`|             | | *SITZUNGEN, PROTOKOLLE UND TERMINE*                                   |                               |             | | Plenarsitzungen                                                       |`get_agenda()`|             | | Stenographisches Protokolle                                           |`get_speeches()`|             | | Parlamentskorrespondenz                                               |`get_index()`|             | | Termine                                                               |`get_calendars()`|             | | Parlamentskorrespondenz                                               |`get_clubs()`|             | | **AUSSCHÜSSE**                                                                                                  |                               |             | | Ausschüsse                                                                                                      |`get_sessions()`|             | | Ausschussmitgliedschaften                                                                                       |`get_petitions()`|             | | Schriftliche Anfragen NR                                                                                         |`get_debate()`|             | | **Anfragen**                                                                                                    |                               |             | | Schriftliche Anfragen BR                                                                                         |`get_bills()`|             | | Stellungnahmen des EU-Hauptausschusses                                                                           |`get_bill_keywords()`|             | | Mitteilungen des EU-Unterausschusses                                                                            |`get_inquiries()`|             | | **EU-Ausschüsse**                                                                                               |                               |             | | Stellungnahmen des Ständigen Unterausschusses des Hauptausschusses (EU)                                         |`get_proceedings()`|             | | Begründete Stellungnahmen des EU-Ausschusses BR                                                                 |`get_topics()`|             | | Mitteilungen des EU-Ausschusses BR                                                                              |`get_mailing_lists()`|             | | **EU-Ausschüsse BR**                                                                                            |                               |             | | Stellungnahmen des EU-Ausschusses BR                                                                            |`get_referendums()\` |  |

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

## References

<!--  -->
