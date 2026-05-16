# GitHub Pages Setup for ParlAT

This document explains how the pkgdown site is deployed to GitHub Pages.

## Overview

The ParlAT package documentation site is automatically built and
deployed to GitHub Pages using GitHub Actions. The site is available at:
<https://werkstattcodes.github.io/ParlAT>

## Workflow Configuration

The `.github/workflows/pkgdown.yaml` workflow:

1.  **Triggers**: Runs on pushes to `main`/`master` branches, pull
    requests, releases, or manual dispatch
2.  **Builds**: Uses
    [`pkgdown::build_site_github_pages()`](https://pkgdown.r-lib.org/reference/build_site_github_pages.html)
    to generate the documentation site
3.  **Deploys**: Pushes the built site to the `gh-pages` branch using
    `JamesIves/github-pages-deploy-action`

## Required Repository Settings

For GitHub Pages to work properly, ensure the following settings are
configured in your GitHub repository:

### 1. Enable GitHub Pages

1.  Go to your repository on GitHub
2.  Navigate to **Settings** → **Pages**
3.  Under “Build and deployment”:
    - **Source**: Select “Deploy from a branch”
    - **Branch**: Select `gh-pages` and `/ (root)` folder
    - Click **Save**

### 2. Workflow Permissions

The workflow requires specific permissions to deploy to GitHub Pages:

- `contents: write` - To push to the gh-pages branch
- `pages: write` - To deploy to GitHub Pages
- `id-token: write` - For OIDC authentication with GitHub Pages

These permissions are already configured in the workflow file.

### 3. Actions Permissions (if needed)

If the workflow fails with permission errors:

1.  Go to **Settings** → **Actions** → **General**
2.  Under “Workflow permissions”:
    - Select “Read and write permissions”
    - Check “Allow GitHub Actions to create and approve pull requests”
    - Click **Save**

## Manual Site Build

To build the site locally for testing:

``` r

# Build the site
pkgdown::build_site()

# Preview the site
pkgdown::preview_site()
```

## Troubleshooting

### Site Not Updating

1.  Check the Actions tab for workflow run status
2.  Verify the `gh-pages` branch exists and has recent commits
3.  Ensure GitHub Pages is enabled and pointing to the `gh-pages` branch
4.  Check that the workflow has the necessary permissions

### Build Failures

1.  Review the workflow logs in the Actions tab
2.  Test the build locally using
    [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
3.  Ensure all dependencies are properly listed in `DESCRIPTION`

## Files Involved

- `.github/workflows/pkgdown.yaml` - GitHub Actions workflow
- `_pkgdown.yml` - pkgdown site configuration
- `DESCRIPTION` - Package metadata including site URL
- `gh-pages` branch - Contains the built site (auto-generated)
