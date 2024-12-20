#' Create Panel
#'
#' This function creates a panel of MPs with their mandates for a given legislative period and institution.
#'
#' @param legis_period Legislative period
#' @param institution Chamber of Parliament. Nationalrat or Bundesrat
#' @return Description of the return value.
#' @examples
#' @export

create_panel <- function(legis_period=NULL, institution=NULL) {

  # Get all MPs
  df_mps_all <- get_mps(legis_period=legis_period, institution = institution)

  #unique pad_interns
  vec_pad_intern <- df_mps_all |> dplyr::distinct(pad_intern) |> dplyr::pull()
  # return(vec_pad_intern)

  #get all their mandates in the respective institution
  df_mandates <- vec_pad_intern |> purrr::map(\(x) get_mandates(pad_intern=x, institution=institution), .progress="Get MPs' mandates") |>
    purrr::list_rbind()

  #if mandate is active mandateBis becomes today's date
  df_mandates <- df_mandates |>
    dplyr::mutate(mandatBis=dplyr::case_when(
      is.na(mandatBis) & aktiv==TRUE ~ lubridate::today(),
      .default=mandatBis
    ))

  #created pad_intern - mandate index; needed to later nest date filling
  df_mandates <- df_mandates |>
    dplyr::group_by(pad_intern) |>
    dplyr::mutate(index_mandate=dplyr::row_number(), .after=pad_intern) |>
    dplyr::ungroup()

  #make longer
  df_mandates_long <- df_mandates |>
    tidyr::pivot_longer(
      cols=c(mandatVon, mandatBis),
      names_to="mandate_date_type",
      values_to="mandate_date"
    ) |>
    dplyr::relocate(c(mandate_date, mandate_date_type), .after=index_mandate)

  #pad; one row per pad_intern - mandate day
  df_mandates_long_pad <- df_mandates_long |>
    padr::pad(interval="day",
              by="mandate_date",
              group=c("pad_intern", "index_mandate"),
              break_above=10)

  cols_fill <- c("mandat", "klub", "wahlkreis", "wahlpartei", "wahlpartei_text", "gremium", "bez",
                 "aktiv", "eingetreten_txt")

  df_mandates_long_pad_fill <- df_mandates_long_pad |>
    tidyr::fill(any_of(cols_fill),.direction="down")

  #ADD NAMES OF MPs
  df_names <- purrr::map(vec_pad_intern, \(x) get_names(pad_intern=x), .progress = "Get MPs name variants") |>
    purrr::list_rbind()

  #for those MPs where the name didn't change, the start and end date of their name is set to today()-100 years and
  #today; facilitates matching with mandate days
  df_names <- df_names |>
    dplyr::mutate(date_start=dplyr::case_when(
      is.na(date_start) ~ lubridate::today()-(100*365),
      .default=date_start
    )) |>
    dplyr::mutate(date_end=dplyr::case_when(
      is.na(date_end) ~ lubridate::today(),
      .default=date_end
    ))

  #join names
  df_mandates_long_pad_fill_names <- df_mandates_long_pad_fill |>
    dplyr::left_join(df_names,
              by=dplyr::join_by(pad_intern, between(mandate_date, date_start, date_end))) |>
    dplyr::select(-date_start, -date_end) |>
    dplyr::rename(
      name_index=index,
      name_value=value)


  df_legis_period <- get_legis_period(legis_period={{legis_period}})

  df_legis_period <- df_legis_period |>
    dplyr::mutate(date_end=dplyr::case_when(
      legis_period_current==TRUE ~ lubridate::today(),
      .default=date_end
    ))


  if (!is.null(legis_period)) {

    df_mandates_long_pad_fill_names <- df_mandates_long_pad_fill_names |>
      dplyr::semi_join(df_legis_period, by=dplyr::join_by(between(mandate_date, date_start, date_end)))

    return(df_mandates_long_pad_fill_names)
  } else {
    df_mandates_long_pad_fill_names
  }

}
