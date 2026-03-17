# Contributing to ParlAT

Thank you for considering contributing to ParlAT! This document outlines how to propose changes to this package.

## Getting Started

1. Fork the repository and clone your fork locally.
2. Create a new branch from `dev` for your changes.
3. Install development dependencies with `devtools::install_dev_deps()`.

## Development Workflow

```r
# Load the package for interactive development
devtools::load_all()

# Regenerate documentation after editing roxygen2 comments
devtools::document()

# Run tests
devtools::test()

# Run R CMD check
devtools::check()
```

## Pull Requests

- Open pull requests against the `dev` branch.
- Include a clear description of the change and the motivation behind it.
- Ensure `devtools::check()` passes with no errors or warnings.
- Add or update tests for any new or changed functionality.
- Update documentation (roxygen2 comments) as needed.

## Code Style

- Use `<-` for assignment (not `=`).
- Use `TRUE` / `FALSE` (not `T` / `F`).
- Follow the [tidyverse style guide](https://style.tidyverse.org/).

## Reporting Bugs

Please open an issue at <https://github.com/werkstattcodes/ParlAT/issues> with a minimal reproducible example.

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inclusive experience for everyone.
