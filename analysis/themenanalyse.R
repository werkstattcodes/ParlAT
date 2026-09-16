# ---------------------------------------------------------------------------
# LLM-gestuetzte Inhaltsanalyse von Stellungnahmen im Begutachtungsverfahren
#
# Funktionsbibliothek. Der eigentliche Ablauf steht in run_themenanalyse.R,
# die Methodik in README.md.
#
# Grundidee: nicht "LLM liest alles und gibt eine Tabelle aus", sondern die
# klassische qualitative Inhaltsanalyse in vier getrennten, einzeln
# pruefbaren Schritten:
#   1. induktive Offenkodierung je Dokument  -> Kritikpunkte + Belegzitat
#   2. Kategorienbildung ueber alle Punkte   -> Codebuch (menschlich zu pruefen)
#   3. deduktive Zuordnung gegen das Codebuch -> numerische Kategorie je Punkt
#   4. Auszaehlung mit dplyr                  -> Haeufigkeitstabellen
# ---------------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(tibble)
library(readr)
library(ellmer)

# Modell zentral konfigurierbar. claude-opus-5 akzeptiert kein temperature/top_p
# (die API antwortet mit 400); die Reproduzierbarkeit kommt daher nicht ueber
# temperature = 0, sondern ueber das eingefrorene Codebuch, die enum-Constraints
# in Stufe 3 und die Doppelkodierung in reliabilitaet_pruefen().
MODELL <- "claude-opus-5"

neuer_chat <- function(system_prompt,
                       effort = NULL,
                       max_tokens = 16000,
                       modell = MODELL) {
  chat_anthropic(
    system_prompt = system_prompt,
    model = modell,
    # cache = "5m" ist Default: der (stabile) System-Prompt wird ueber alle
    # Requests hinweg gecached, was bei hunderten Zuordnungen spuerbar spart.
    params = params(max_tokens = max_tokens, reasoning_effort = effort)
  )
}


# --- Korpus ----------------------------------------------------------------

#' Stellungnahmen aus einem Verzeichnis einlesen
#'
#' Erwartet .txt/.md. Fuer PDF vorher pdftools::pdf_text(), fuer DOCX
#' officer::read_docx() |> officer::docx_summary() und das Ergebnis als .txt
#' ablegen - die Extraktion gehoert bewusst nicht in die Analyse-Pipeline.
#'
#' Optional kann eine Metadaten-CSV mit den Spalten `datei` und `organisation`
#' (und beliebigen weiteren Spalten) danebengelegt werden.
korpus_einlesen <- function(pfad, meta_datei = NULL, muster = "\\.(txt|md)$") {
  dateien <- list.files(pfad, pattern = muster, full.names = TRUE)
  if (length(dateien) == 0) {
    stop("Keine Dokumente in '", pfad, "' gefunden.", call. = FALSE)
  }

  korpus <- tibble(
    datei = basename(dateien),
    text = map_chr(dateien, \(f) paste(read_lines(f), collapse = "\n"))
  ) |>
    mutate(
      # Zeilenenden und Wortabstaende normalisieren, Absatzgrenzen aber
      # erhalten - in_abschnitte_teilen() schneidet an "\n\n".
      text = text |>
        str_replace_all("\r\n", "\n") |>
        str_replace_all("[ \t]+", " ") |>
        str_replace_all(" ?\n ?", "\n") |>
        str_replace_all("\n{3,}", "\n\n") |>
        str_trim(),
      doc_id = sprintf("D%03d", row_number()),
      n_zeichen = nchar(text),
      .before = 1
    )

  if (!is.null(meta_datei) && file.exists(meta_datei)) {
    korpus <- left_join(korpus, read_csv(meta_datei, show_col_types = FALSE),
                        by = "datei")
  }
  if (!"organisation" %in% names(korpus)) {
    korpus <- mutate(korpus, organisation = str_remove(datei, "\\.[^.]+$"))
  }

  korpus
}

#' Lange Stellungnahmen in Abschnitte teilen
#'
#' Nicht wegen des Kontextfensters (1 Mio. Tokens reichen), sondern wegen der
#' Trefferquote: ueber 30+ Seiten hinweg ueberliest ein Modell einzelne Punkte.
#' Geschnitten wird an Absatzgrenzen, damit Zitate intakt bleiben.
in_abschnitte_teilen <- function(korpus, max_zeichen = 40000) {
  korpus |>
    mutate(absatz = str_split(text, "\n\n")) |>
    select(-text) |>
    unnest(absatz) |>
    filter(str_squish(absatz) != "") |>
    group_by(doc_id) |>
    mutate(
      # kumulative Laenge, bei Ueberschreiten faengt ein neuer Abschnitt an
      block = (cumsum(nchar(absatz)) - 1) %/% max_zeichen
    ) |>
    group_by(doc_id, block) |>
    summarise(
      across(c(datei, organisation), first),
      text = paste(absatz, collapse = "\n\n"),
      .groups = "drop"
    ) |>
    group_by(doc_id) |>
    mutate(abschnitt_id = str_c(doc_id, "-", sprintf("%02d", row_number()))) |>
    ungroup() |>
    select(abschnitt_id, doc_id, datei, organisation, text)
}


# --- Stufe 1: induktive Offenkodierung --------------------------------------

typ_offene_kodierung <- function() {
  type_object(
    "Alle inhaltlichen Punkte, die der Text zum Begutachtungsgegenstand vorbringt.",
    punkte = type_array(
      type_object(
        kurztitel = type_string(
          "Praegnante Bezeichnung des Punktes, hoechstens acht Woerter, ohne Wertung des Kodierers."
        ),
        beschreibung = type_string(
          "Ein bis zwei Saetze: was genau wird kritisiert, gefordert oder begruesst, und mit welcher Begruendung."
        ),
        zitat = type_string(
          "Woertliches, unveraendertes Zitat aus dem Text, das den Punkt belegt. Hoechstens 40 Woerter."
        ),
        bezug = type_string(
          "Betroffene Bestimmung des Entwurfs, z.B. '§ 4 Abs. 2' oder 'Art. 90b B-VG'. Wenn der Text keine nennt: 'allgemein'."
        ),
        stossrichtung = type_enum(
          c("ablehnend", "kritisch", "aenderungsvorschlag", "zustimmend", "neutral"),
          "Haltung des Textes an dieser Stelle."
        )
      ),
      "Ein Eintrag je eigenstaendigem Sachpunkt."
    )
  )
}

prompt_offene_kodierung <- function(gegenstand) {
  str_glue("
    Du kodierst Stellungnahmen aus einem oesterreichischen Begutachtungsverfahren \\
    fuer eine qualitative Inhaltsanalyse. Begutachtungsgegenstand: {gegenstand}.

    Deine Aufgabe ist reine Extraktion, keine Bewertung und keine Zusammenfassung.

    Regeln:
    - Erfasse jeden eigenstaendigen Sachpunkt einzeln. Bringt ein Text zu einer \\
      Bestimmung zwei getrennte Einwaende vor, sind das zwei Eintraege.
    - Fasse nicht zusammen und buendle nicht: 'mehrere Bedenken zur Weisungsspitze' \\
      ist kein zulaessiger Eintrag.
    - Erfinde nichts. Jeder Eintrag braucht ein woertliches Belegzitat aus dem \\
      vorgelegten Text. Findest du kein Zitat, gehoert der Punkt nicht in die Liste.
    - Uebernimm das Zitat zeichengetreu; kuerze allenfalls mit [...].
    - Ignoriere Formalien: Anrede, Dank, Verteilerhinweise, Uebermittlungsformeln, \\
      Hinweise auf die elektronische Einbringung.
    - Bleibe nah an der Formulierung des Textes; uebersetze juristische Begriffe nicht \\
      in Alltagssprache.
    - Bringt ein Abschnitt keinen Punkt zum Gegenstand, gib eine leere Liste zurueck.
  ")
}

#' Stufe 1 ausfuehren
offen_kodieren <- function(abschnitte, gegenstand, effort = NULL, ...) {
  chat <- neuer_chat(prompt_offene_kodierung(gegenstand), effort = effort)

  prompts <- str_glue_data(abschnitte, "
    Stellungnahme von: {organisation}
    Dokument-ID: {doc_id}, Abschnitt: {abschnitt_id}

    <text>
    {text}
    </text>

    Extrahiere alle Sachpunkte dieses Abschnitts zum Begutachtungsgegenstand.
  ")

  ergebnis <- parallel_chat_structured(
    chat,
    as.character(prompts),
    type = typ_offene_kodierung(),
    on_error = "continue",
    ...
  )

  abschnitte |>
    select(abschnitt_id, doc_id, datei, organisation) |>
    mutate(punkte = ergebnis$punkte) |>
    filter(map_lgl(punkte, \(x) is.data.frame(x) && nrow(x) > 0)) |>
    unnest(punkte) |>
    mutate(punkt_id = sprintf("P%04d", row_number()), .before = 1)
}


# --- Stufe 2: Kategorienbildung ---------------------------------------------

typ_codebuch <- function() {
  type_object(
    "Kategoriensystem fuer die vorgelegten Kodiereinheiten.",
    kategorien = type_array(
      type_object(
        kategorie_id = type_string(
          "Kurz-ID in snake_case, z.B. 'weisungsspitze_kollegialorgan'. Stabil und eindeutig."
        ),
        label = type_string("Kategorienname, hoechstens fuenf Woerter."),
        definition = type_string(
          "Zwei bis drei Saetze: welche Punkte fallen in diese Kategorie."
        ),
        abgrenzung = type_string(
          "Was faellt ausdruecklich NICHT hinein, insbesondere Abgrenzung zur aehnlichsten anderen Kategorie."
        ),
        ankerbeispiele = type_array(
          type_string(),
          "Zwei bis drei Kurztitel aus der vorgelegten Liste, die typisch fuer die Kategorie sind."
        )
      ),
      "Die Kategorien des Systems."
    )
  )
}

#' Stufe 2 ausfuehren: ein einziger Aufruf ueber alle Kurztitel
#'
#' Bewusst nicht ueber die Volltexte - das Kategoriensystem soll aus den
#' extrahierten Punkten entstehen, nicht aus dem Rauschen der Dokumente.
codebuch_erzeugen <- function(punkte, gegenstand, n_min = 10, n_max = 18,
                              effort = NULL) {
  system_prompt <- str_glue("
    Du entwickelst das Kategoriensystem einer qualitativen Inhaltsanalyse zu \\
    Stellungnahmen im oesterreichischen Begutachtungsverfahren. \\
    Begutachtungsgegenstand: {gegenstand}.

    Anforderungen an das System:
    - {n_min} bis {n_max} Kategorien, sortiert nach Haeufigkeit der zugehoerigen Punkte.
    - Trennscharf: jeder vorgelegte Punkt muss sich genau einer Kategorie zuordnen lassen.
    - Erschoepfend: jeder vorgelegte Punkt muss unterkommen. Lege notfalls eine \\
      Kategorie 'sonstiges' an, aber nur fuer echte Einzelfaelle.
    - Auf gleicher Abstraktionsebene. Nicht eine Kategorie 'Rechtsstaatlichkeit' \\
      neben einer Kategorie 'Frist in § 12 Abs. 3'.
    - Sachlich benannt, nicht wertend. 'Kosten und Ressourcen', nicht 'unrealistische Kosten'.
    - Die Kategorien bilden ab, WORUEBER gesprochen wird, nicht MIT WELCHER HALTUNG. \\
      Zustimmung und Ablehnung zum selben Thema gehoeren in dieselbe Kategorie; \\
      die Haltung wird separat als stossrichtung gefuehrt.
  ")

  liste <- punkte |>
    distinct(kurztitel, .keep_all = TRUE) |>
    mutate(zeile = str_glue("- {kurztitel}: {beschreibung}")) |>
    pull(zeile) |>
    paste(collapse = "\n")

  chat <- neuer_chat(system_prompt, effort = effort, max_tokens = 32000)

  ergebnis <- chat$chat_structured(
    str_glue("
      Nachfolgend alle Punkte, die aus {n_distinct(punkte$doc_id)} Stellungnahmen \\
      extrahiert wurden ({nrow(punkte)} Punkte, {n_distinct(punkte$kurztitel)} \\
      verschiedene Kurztitel).

      <punkte>
      {liste}
      </punkte>

      Entwickle daraus das Kategoriensystem.
    "),
    type = typ_codebuch()
  )

  ergebnis$kategorien |>
    as_tibble() |>
    mutate(
      kategorie_nr = row_number(),
      ankerbeispiele = map_chr(ankerbeispiele, \(x) paste(x, collapse = " | ")),
      .before = 1
    )
}

codebuch_schreiben <- function(codebuch, pfad) {
  write_csv(codebuch, pfad)
  message("Codebuch nach '", pfad, "' geschrieben. ",
          "Jetzt pruefen und bei Bedarf haendisch korrigieren, ",
          "bevor Stufe 3 laeuft.")
  invisible(pfad)
}

codebuch_lesen <- function(pfad) {
  cb <- read_csv(pfad, show_col_types = FALSE)
  stopifnot(
    all(c("kategorie_id", "label", "definition") %in% names(cb)),
    !any(duplicated(cb$kategorie_id))
  )
  cb
}


# --- Stufe 3: deduktive Zuordnung -------------------------------------------

typ_zuordnung <- function(codebuch) {
  type_object(
    "Zuordnung eines Punktes zum Kategoriensystem.",
    kategorie_id = type_enum(
      codebuch$kategorie_id,
      "Die eine Kategorie, die den Punkt am besten erfasst."
    ),
    konfidenz = type_enum(
      c("hoch", "mittel", "niedrig"),
      "Wie eindeutig ist die Zuordnung? 'niedrig', wenn zwei Kategorien gleich gut passen."
    ),
    begruendung = type_string(
      "Ein Satz, warum diese Kategorie und nicht die naechstaehnliche."
    )
  )
}

prompt_zuordnung <- function(codebuch, gegenstand) {
  kategorien <- codebuch |>
    mutate(block = str_glue(
      "## {kategorie_id}\nLabel: {label}\nDefinition: {definition}\nAbgrenzung: {abgrenzung}"
    )) |>
    pull(block) |>
    paste(collapse = "\n\n")

  str_glue("
    Du kodierst Punkte aus Stellungnahmen (Begutachtungsgegenstand: {gegenstand}) \\
    gegen ein festes Kategoriensystem.

    Regeln:
    - Ordne genau eine Kategorie zu. Das System ist verbindlich; erfinde keine \\
      neuen Kategorien und veraendere keine IDs.
    - Entscheide nach der Definition, nicht nach Wortaehnlichkeit zum Label.
    - Passen zwei Kategorien gleich gut, waehle die spezifischere und setze \\
      konfidenz auf 'niedrig'.
    - Die Haltung des Punktes (zustimmend/ablehnend) ist fuer die Zuordnung \\
      unerheblich.

    <kategoriensystem>
    {kategorien}
    </kategoriensystem>
  ")
}

#' Stufe 3 ausfuehren
#'
#' Eine Anfrage je Punkt. Das Kategoriensystem steht im System-Prompt und wird
#' daher von Anthropic gecached (ellmer setzt cache = '5m' per Default).
#' effort = "low" reicht: die Entscheidung ist mechanisch, das Codebuch liegt vor.
punkte_zuordnen <- function(punkte, codebuch, gegenstand, effort = "low", ...) {
  chat <- neuer_chat(prompt_zuordnung(codebuch, gegenstand),
                     effort = effort, max_tokens = 2000)

  prompts <- str_glue_data(punkte, "
    Kurztitel: {kurztitel}
    Beschreibung: {beschreibung}
    Bezug: {bezug}
    Belegzitat: \"{zitat}\"

    Welche Kategorie?
  ")

  ergebnis <- parallel_chat_structured(
    chat,
    as.character(prompts),
    type = typ_zuordnung(codebuch),
    on_error = "continue",
    ...
  )

  punkte |>
    bind_cols(as_tibble(ergebnis)) |>
    left_join(select(codebuch, kategorie_id, kategorie_nr, label), by = "kategorie_id")
}


# --- Stufe 4: Auszaehlung ---------------------------------------------------

#' Haeufigkeitstabellen
#'
#' Zwei Zaehleinheiten, die sich unterscheiden und beide berichtet werden sollten:
#' - n_nennungen: wie oft wurde das Thema insgesamt vorgebracht (ein Dokument
#'   kann ein Thema mehrfach ansprechen und zaehlt dann mehrfach)
#' - n_dokumente: in wie vielen Stellungnahmen kommt das Thema ueberhaupt vor
#'   (robuster gegen einzelne sehr lange Stellungnahmen; in der Regel die
#'   aussagekraeftigere Zahl)
haeufigkeiten <- function(zuordnungen, codebuch, korpus) {
  n_docs <- n_distinct(korpus$doc_id)

  nennungen <- zuordnungen |>
    count(kategorie_id, name = "n_nennungen")

  dokumente <- zuordnungen |>
    distinct(doc_id, kategorie_id) |>
    count(kategorie_id, name = "n_dokumente")

  codebuch |>
    select(kategorie_nr, kategorie_id, label, definition) |>
    left_join(nennungen, by = "kategorie_id") |>
    left_join(dokumente, by = "kategorie_id") |>
    mutate(
      across(c(n_nennungen, n_dokumente), \(x) coalesce(x, 0L)),
      anteil_dokumente = n_dokumente / n_docs,
      anteil_nennungen = n_nennungen / sum(n_nennungen)
    ) |>
    arrange(desc(n_dokumente), desc(n_nennungen))
}

#' Kreuztabelle Kategorie x Haltung
haeufigkeiten_nach_stossrichtung <- function(zuordnungen) {
  zuordnungen |>
    count(kategorie_id, label, stossrichtung) |>
    pivot_wider(names_from = stossrichtung, values_from = n, values_fill = 0) |>
    mutate(gesamt = rowSums(across(where(is.numeric)))) |>
    arrange(desc(gesamt))
}

#' Dokument-x-Kategorie-Matrix (0/1) - die "numerische Kategorisierung"
dokument_kategorie_matrix <- function(zuordnungen, codebuch, korpus) {
  korpus |>
    select(doc_id, organisation) |>
    cross_join(select(codebuch, kategorie_id)) |>
    left_join(
      zuordnungen |> distinct(doc_id, kategorie_id) |> mutate(vorhanden = 1L),
      by = c("doc_id", "kategorie_id")
    ) |>
    mutate(vorhanden = coalesce(vorhanden, 0L)) |>
    pivot_wider(names_from = kategorie_id, values_from = vorhanden)
}


# --- Stufe 5: Guetepruefung -------------------------------------------------

#' Stufe 3 ein zweites Mal laufen lassen und die Uebereinstimmung messen
#'
#' Ohne temperature-Steuerung (Opus 5 akzeptiert sie nicht) ist das die
#' belastbare Art, die Stabilitaet der Kodierung zu zeigen. Werte unter etwa
#' 0.8 Uebereinstimmung heissen: Codebuch nachschaerfen (meist die Abgrenzung
#' zwischen zwei Kategorien), nicht Ergebnisse berichten.
reliabilitaet_pruefen <- function(punkte, codebuch, gegenstand, zuordnungen_1,
                                  n = 100, effort = "low") {
  stichprobe <- slice_sample(punkte, n = min(n, nrow(punkte)))
  zweit <- punkte_zuordnen(stichprobe, codebuch, gegenstand, effort = effort)

  vergleich <- zuordnungen_1 |>
    select(punkt_id, kat_1 = kategorie_id) |>
    inner_join(select(zweit, punkt_id, kat_2 = kategorie_id), by = "punkt_id") |>
    mutate(gleich = kat_1 == kat_2)

  kappa <- NA_real_
  if (requireNamespace("irr", quietly = TRUE)) {
    kappa <- irr::kappa2(as.data.frame(select(vergleich, kat_1, kat_2)))$value
  }

  list(
    uebereinstimmung = mean(vergleich$gleich),
    kappa = kappa,
    abweichungen = filter(vergleich, !gleich)
  )
}

#' Stichprobe fuer die manuelle Validierung exportieren
#'
#' Der unverzichtbare Schritt: ~50 Punkte selbst kodieren und gegen die
#' Maschinenkodierung halten. Erst danach sind die Haeufigkeiten belastbar.
goldstandard_export <- function(zuordnungen, pfad, n = 50) {
  zuordnungen |>
    slice_sample(n = min(n, nrow(zuordnungen))) |>
    transmute(
      punkt_id, doc_id, organisation, kurztitel, beschreibung, zitat, bezug,
      kategorie_maschine = kategorie_id,
      konfidenz,
      kategorie_manuell = NA_character_,
      anmerkung = NA_character_
    ) |>
    write_csv(pfad)
  message("Validierungsstichprobe nach '", pfad, "'. ",
          "Spalte 'kategorie_manuell' haendisch ausfuellen, ",
          "ohne vorher auf 'kategorie_maschine' zu schauen.")
  invisible(pfad)
}
