# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

ParlAT is an R package that provides a wrapper for the Austrian
Parliament’s API, enabling easy access to open parliamentary data. The
package is in early development stage and follows standard R package
conventions.

## Development Commands

### Package Building and Checking

``` r
# Build package documentation
devtools::document()

# Build and check package
devtools::check()

# Install package locally
devtools::install()

# Load package for development
devtools::load_all()
```

### Testing

``` r
# Run all tests
devtools::test()

# Run specific test file
testthat::test_file("tests/testthat/test-get_mps.R")

# Test with coverage
covr::package_coverage()
```

### Documentation

``` r
# Build vignettes
devtools::build_vignettes()

# Preview documentation site
pkgdown::build_site()
```

## Architecture and Code Patterns

### Core API Functions

The package follows a consistent pattern for API wrapper functions:

- **Main API functions**: Located in `R/` directory, each handling
  specific parliamentary data types
- **Naming convention**: `get_*()` functions for retrieving data (e.g.,
  [`get_mps()`](https://werkstattcodes.github.io/ParlAT/reference/get_mps.md),
  [`get_items()`](https://werkstattcodes.github.io/ParlAT/reference/get_items.md),
  [`get_committees()`](https://werkstattcodes.github.io/ParlAT/reference/get_committees.md))
- **Parameter validation**: Uses `checkmate` package for input
  validation
- **HTTP requests**: Built on `httr2` for robust API communication
- **Data processing**: Returns tibbles using `dplyr` and `tibble`
  packages

### Function Categories

1.  **Primary data retrieval functions**:
    - [`get_mps()`](https://werkstattcodes.github.io/ParlAT/reference/get_mps.md) -
      Members of Parliament since 1918
    - [`get_items()`](https://werkstattcodes.github.io/ParlAT/reference/get_items.md) -
      Parliamentary items/proceedings
    - [`get_item_details()`](https://werkstattcodes.github.io/ParlAT/reference/get_item_details.md) -
      Detailed information for specific parliamentary items via URL
    - [`get_committees()`](https://werkstattcodes.github.io/ParlAT/reference/get_committees.md) -
      Committee information
    - [`get_events()`](https://werkstattcodes.github.io/ParlAT/reference/get_events.md) -
      Parliamentary events
    - [`get_plenary_sessions()`](https://werkstattcodes.github.io/ParlAT/reference/get_plenary_sessions.md) -
      Plenary session data
    - [`get_legis_periods()`](https://werkstattcodes.github.io/ParlAT/reference/get_legis_periods.md) -
      Legislative periods
    - [`get_mandates()`](https://werkstattcodes.github.io/ParlAT/reference/get_mandates.md) -
      MP mandates and terms
    - [`get_participation()`](https://werkstattcodes.github.io/ParlAT/reference/get_participation.md) -
      Public participation/consultation data
    - [`get_persons()`](https://werkstattcodes.github.io/ParlAT/reference/get_persons.md) -
      Person-related data
    - `get_protocols()` - Parliamentary protocols
    - `get_inquiries_and_responses()` - Parliamentary questions and
      answers
2.  **Auxiliary/utility functions** (prefix: `aux_`):
    - `aux_check_legis_period.R` - Legislative period validation and
      conversion
    - `aux_check_pad_intern_exists()` - Validates person identifiers
    - `aux_parl_group_names_standard()` - Standardizes party names
3.  **Specialized data functions**:
    - [`get_mps_current()`](https://werkstattcodes.github.io/ParlAT/reference/get_mps_current.md) -
      Currently active MPs
    - [`get_mps_details()`](https://werkstattcodes.github.io/ParlAT/reference/get_mps_details.md) -
      Detailed MP information
    - `get_committee_memberships()` - Committee membership data
    - `create_panel()` - Panel data creation utilities
    - [`get_names()`](https://werkstattcodes.github.io/ParlAT/reference/get_names.md) -
      Name standardization utilities

### Key Dependencies

- **httr2**: HTTP client for API requests
- **dplyr/tibble**: Data manipulation and structure
- **checkmate**: Parameter validation
- **jsonlite**: JSON processing
- **purrr**: Functional programming utilities
- **stringr**: String manipulation
- **rvest**: HTML parsing for mixed content
- **glue**: String interpolation for API URLs
- **janitor**: Data cleaning utilities
- **padr**: Date/time manipulation for time series
- **progress**: Progress bars for long-running operations

### Testing Strategy

- Uses `testthat` framework with edition 3
- `httptest2` for mocking HTTP requests during testing
- Test files follow `test-*.R` or `test_*.R` naming convention
- Setup in `tests/testthat/setup.R` loads `httptest2`
- Tests include both unit tests and integration tests with API calls
- Use `skip_on_cran()` and `skip_if_offline()` for conditional testing
- Mock API responses stored in `tests/testthat/` directory for
  consistent testing

### Data Processing Patterns

- All API responses are converted to tibbles
- HTML content is parsed using `rvest` for clean text extraction
- Legislative periods are standardized (numeric to Roman numeral
  conversion via [`as.roman()`](https://rdrr.io/r/utils/roman.html))
- Consistent parameter naming across functions (e.g., `legis_period`,
  `institution`)
- URL construction uses `glue` for readable string interpolation
- Progress tracking with `progress` package for long-running API calls

### Error Handling

- Robust parameter validation using `checkmate`
- HTTP error handling through `httr2`
- Network connectivity checks in tests
- Clear error messages for invalid inputs

### Documentation Standards

- Functions documented with roxygen2
- Examples in documentation (often with `\dontrun{}` for API calls)
- Detailed parameter descriptions including permitted values
- Vignette (`vignettes/ParlAT.Rmd`) provides usage examples

## Common Development Tasks

### Adding New API Endpoints

1.  Create new `get_*()` function in `R/` directory
2.  Follow existing parameter validation patterns using `checkmate`
3.  Use `httr2` for HTTP requests
4.  Add corresponding test file in `tests/testthat/`
5.  Update `NAMESPACE` by running
    [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
6.  Update README.md table if needed

### Modifying Existing Functions

1.  Check existing tests first to understand expected behavior
2.  Maintain backward compatibility for public functions
3.  Update tests if changing function behavior
4.  Re-run
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    before committing

### Testing New Features

1.  Add tests to appropriate `test-*.R` file
2.  Use
    [`httptest2::with_mock_api()`](https://enpiar.com/httptest2/reference/with_mock_api.html)
    for consistent testing
3.  Include both success and error scenarios
4.  Test parameter validation edge cases

## Special Considerations

### Legislative Period Handling

- The package handles both numeric (27) and Roman numeral (XXVII) inputs
- Historical periods use special codes: “PN” (Provisional National
  Assembly), “KN” (Constituent National Assembly)
- Conversion functions in `aux_check_legis_period.R` handle
  standardization

### Parliamentary Group Names

- Austrian political parties have complex naming histories
- `aux_parl_group_names_standard()` expands party abbreviations to
  include historical variants
- FPÖ includes variants like “F”, “F-BZÖ”
- NEOS includes “NEOS-LIF”

### API Response Processing

- Mixed HTML/text content requires `rvest` parsing
- Person identifiers (`pad_intern`) can be validated using
  `aux_check_pad_intern_exists()`
- List-column data structures preserved where appropriate

## Package Metadata

- **License**: GPL (\>= 3)
- **URL**: <https://github.com/werkstattcodes/ParlAT>
- **Documentation**: <https://werkstattcodes.github.io/ParlAT/>
- **Minimum R version**: R (\>= 2.10)
