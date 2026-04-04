# Transform Event Date for API Request

Helper function to convert date from dd-mm-yyyy format to ISO 8601 UTC
format required by the Austrian Parliament API.

## Usage

``` r
aux_transform_event_date(date_string, param_name, is_end_date = FALSE)
```

## Arguments

- date_string:

  Character string in "dd-mm-yyyy" format or NULL

- param_name:

  Name of the parameter for error messages

- is_end_date:

  Logical indicating if this is an end date (adds 1 day minus 1 second)

## Value

Character string in ISO 8601 format or NULL
