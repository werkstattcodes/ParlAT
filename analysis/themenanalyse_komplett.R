# ===========================================================================
# Themenanalyse von Stellungnahmen im Begutachtungsverfahren
#
# Welche Vorbehalte bringen die Stellungnahmen gegen den Ministerialentwurf
# vor, und wie oft kommt jedes Thema ueber alle Dokumente hinweg vor?
#
# Zwei Wege zur selben Frage, beide hier drin:
#   Variante A - ein einziger Aufruf ueber alle Dokumente (Abschnitt C)
#   Variante B - mehrstufig, Dokument fuer Dokument      (Abschnitt D)
# Beide liefern dieselbe Ergebnisform, deshalb teilen sie sich Auszaehlung
# (E) und lassen sich direkt vergleichen (F).
#
# Block fuer Block ausfuehren, nicht am Stueck sourcen: zwischen D2 und D3
# liegt ein Halt, an dem das Kategoriensystem haendisch geprueft wird.
#
# Voraussetzungen:
#   install.packages(c("ellmer", "tidyverse"))
#   Sys.setenv(ANTHROPIC_API_KEY = "...")     # besser: ~/.Renviron
#   Stellungnahmen als .txt in DATEN, optional meta.csv (datei, organisation)
# ===========================================================================

library(ellmer)
library(tidyverse)


# === A  Konfiguration ======================================================

MODELL <- "claude-opus-5"
DATEN  <- "analysis/daten"
OUT    <- "analysis/output"

GEGENSTAND <- paste(
  "der Ministerialentwurf zur Einrichtung einer Bundesstaatsanwaltschaft",
  "(Weisungsspitze in Strafsachen anstelle des Bundesministers fuer Justiz)"
)
N_THEMEN_MAX <- 10

# claude-opus-5 nimmt kein temperature/top_p mehr entgegen - die API antwortet
# mit 400. Reproduzierbarkeit kommt hier aus dem eingefrorenen Codebuch, den
# type_enum-Beschraenkungen und der Wiederholungsmessung in Abschnitt G.
neuer_chat <- function(system_prompt, effort = NULL, max_tokens = 16000) {
  chat_anthropic(
    system_prompt = system_prompt,
    model = MODELL,
    # cache = "5m" ist Default; ellmer setzt cache_control auf den System-Prompt
    # und den letzten Content-Block, wiederholte Laeufe treffen also den Cache.
    params = params(max_tokens = max_tokens, reasoning_effort = effort)
  )
}

# Beide Varianten liefern diese Form - darauf setzen E und F auf:
#   doc_id | organisation | thema_id | label | zitat
NENNUNG_SPALTEN <- c("doc_id", "organisation", "thema_id", "label", "zitat")

pruefe_form <- function(nennungen, wer) {
  fehlt <- setdiff(NENNUNG_SPALTEN, names(nennungen))
  if (length(fehlt)) stop(wer, ": Spalten fehlen: ", paste(fehlt, collapse = ", "))
  invisible(nennungen)
}


# === B  Korpus =============================================================

korpus_einlesen <- function(pfad = DATEN, meta = file.path(pfad, "meta.csv")) {
  dateien <- list.files(pfad, "\\.(txt|md)$", full.names = TRUE)
  if (!length(dateien)) stop("Keine Dokumente in '", pfad, "'.")

  k <- tibble(
    datei = basename(dateien),
    text = map_chr(dateien, \(f) paste(read_lines(f), collapse = "\n"))
  ) |>
    mutate(
      # Whitespace normalisieren, Absatzgrenzen aber erhalten
      text = text |>
        str_replace_all("\r\n", "\n") |>
        str_replace_all("[ \t]+", " ") |>
        str_replace_all(" ?\n ?", "\n") |>
        str_replace_all("\n{3,}", "\n\n") |>
        str_trim(),
      doc_id = sprintf("D%02d", row_number()),
      n_zeichen = nchar(text),
      rang = row_number(),        # Position im zusammengesetzten Prompt (Variante A)
      .before = 1
    )

  if (file.exists(meta)) {
    k <- left_join(k, read_csv(meta, show_col_types = FALSE), by = "datei")
  }
  if (!"organisation" %in% names(k)) {
    k <- mutate(k, organisation = str_remove(datei, "\\.[^.]+$"))
  }
  k
}

# Lange Dokumente stueckeln - nicht wegen des Kontextfensters (1 Mio. Tokens),
# sondern wegen der Trefferquote. Nur fuer Variante B.
in_abschnitte_teilen <- function(korpus, max_zeichen = 40000) {
  korpus |>
    select(doc_id, organisation, text) |>
    mutate(absatz = str_split(text, "\n\n")) |>
    select(-text) |>
    unnest(absatz) |>
    filter(str_squish(absatz) != "") |>
    group_by(doc_id) |>
    mutate(block = (cumsum(nchar(absatz)) - 1) %/% max_zeichen) |>
    group_by(doc_id, block) |>
    summarise(organisation = first(organisation),
              text = paste(absatz, collapse = "\n\n"), .groups = "drop") |>
    group_by(doc_id) |>
    mutate(abschnitt_id = str_c(doc_id, "-", sprintf("%02d", row_number()))) |>
    ungroup() |>
    select(abschnitt_id, doc_id, organisation, text)
}


# === C  Variante A: ein einziger Aufruf ====================================

# nennungen ist ein Array von OBJEKTEN, nicht zwei parallele Arrays fuer
# Organisation und Zitat - parallele Arrays laufen auseinander.
typ_themen_gesamt <- function(n_max) {
  type_object(
    "Die Themen, unter denen die Stellungnahmen Vorbehalte vorbringen.",
    themen = type_array(
      type_object(
        thema_id   = type_string("Kurz-ID in snake_case, z.B. 'politische_einflussnahme'."),
        label      = type_string("Themenname, hoechstens fuenf Woerter."),
        definition = type_string("Was faellt unter dieses Thema, was nicht? Zwei Saetze."),
        nennungen  = type_array(
          type_object(
            organisation = type_string("Name exakt wie im Attribut organisation."),
            zitat = type_string("Woertliches Belegzitat aus genau dieser Stellungnahme.")
          ),
          "Eine Nennung je Stellungnahme, die diesen Vorbehalt vorbringt."
        )
      ),
      paste0("Hoechstens ", n_max, " Themen, nach Anzahl der Nennungen sortiert.")
    )
  )
}

variante_a <- function(korpus, gegenstand = GEGENSTAND, n_max = N_THEMEN_MAX) {
  alle <- korpus |>
    str_glue_data('<stellungnahme organisation="{organisation}">\n{text}\n</stellungnahme>') |>
    paste(collapse = "\n\n")

  chat <- neuer_chat(str_glue("
    Du wertest Stellungnahmen aus einem oesterreichischen Begutachtungsverfahren \\
    aus. Begutachtungsgegenstand: {gegenstand}.

    Erfasse ausschliesslich Vorbehalte, Bedenken und Kritikpunkte der Verfasser - \\
    keine Zustimmung, keine Formalien wie Dank oder Verteilerhinweise.

    Gruppiere sie zu hoechstens {n_max} trennscharfen Themen auf gleicher \\
    Abstraktionsebene, sachlich benannt, nicht wertend.

    Arbeite jede Stellungnahme einzeln durch, bevor du gruppierst. Uebergehe \\
    keine, auch nicht die in der Mitte des Materials. Jede Nennung braucht ein \\
    woertliches Belegzitat aus genau der Stellungnahme, der sie zugeordnet wird.
  "), max_tokens = 32000)

  dauer <- system.time(
    erg <- chat$chat_structured(
      paste0("Hier sind alle ", nrow(korpus), " Stellungnahmen.\n\n", alle),
      type = typ_themen_gesamt(n_max)
    )
  )

  themen <- as_tibble(erg$themen) |> mutate(thema_nr = row_number(), .before = 1)

  nennungen <- themen |>
    select(thema_id, label, nennungen) |>
    unnest(nennungen) |>
    # Das Modell tippt Organisationsnamen ab - hier faellt auf, wenn es
    # danebengreift ("Beispielverband e.V." statt "Beispielverband").
    left_join(select(korpus, doc_id, organisation), by = "organisation")

  unbekannt <- filter(nennungen, is.na(doc_id))
  if (nrow(unbekannt)) {
    warning("Variante A: ", nrow(unbekannt), " Nennungen mit unbekannter ",
            "Organisation: ", paste(unique(unbekannt$organisation), collapse = ", "))
  }

  list(
    themen = select(themen, thema_nr, thema_id, label, definition),
    nennungen = pruefe_form(select(nennungen, all_of(NENNUNG_SPALTEN)), "Variante A"),
    dauer = unname(dauer[["elapsed"]])
  )
}


# === D  Variante B: mehrstufig =============================================

# --- D1  Induktive Offenkodierung ------------------------------------------

typ_punkte <- type_object(
  "Alle Vorbehalte, die der Text zum Begutachtungsgegenstand vorbringt.",
  punkte = type_array(
    type_object(
      kurztitel    = type_string("Praegnante Bezeichnung, hoechstens acht Woerter."),
      beschreibung = type_string("Ein bis zwei Saetze: was genau wird bemaengelt."),
      zitat        = type_string("Woertliches, unveraendertes Belegzitat. Max. 40 Woerter."),
      bezug        = type_string("Betroffene Bestimmung, z.B. '§ 4 Abs. 2'. Sonst 'allgemein'.")
    ),
    "Ein Eintrag je eigenstaendigem Vorbehalt."
  )
)

b1_offen_kodieren <- function(abschnitte, gegenstand = GEGENSTAND) {
  chat <- neuer_chat(str_glue("
    Du kodierst Stellungnahmen aus einem oesterreichischen Begutachtungsverfahren \\
    fuer eine qualitative Inhaltsanalyse. Begutachtungsgegenstand: {gegenstand}.

    Reine Extraktion, keine Bewertung, keine Zusammenfassung.

    - Erfasse ausschliesslich Vorbehalte, Bedenken und Kritikpunkte.
    - Jeder eigenstaendige Vorbehalt ist ein eigener Eintrag. Nicht buendeln.
    - Erfinde nichts: jeder Eintrag braucht ein woertliches Belegzitat. Kein \\
      Zitat, kein Eintrag.
    - Ignoriere Anrede, Dank, Verteilerhinweise, Uebermittlungsformeln.
    - Bringt ein Abschnitt keinen Vorbehalt, gib eine leere Liste zurueck.
  "))

  erg <- parallel_chat_structured(
    chat,
    as.character(str_glue_data(abschnitte,
      "Stellungnahme von {organisation} ({abschnitt_id}):\n\n<text>\n{text}\n</text>")),
    type = typ_punkte,
    on_error = "continue"
  )

  abschnitte |>
    select(abschnitt_id, doc_id, organisation) |>
    mutate(p = erg$punkte) |>
    filter(map_lgl(p, \(x) is.data.frame(x) && nrow(x) > 0)) |>
    unnest(p) |>
    mutate(punkt_id = sprintf("P%04d", row_number()), .before = 1)
}

# --- D2  Kategorienbildung -------------------------------------------------

typ_codebuch <- type_object(
  "Kategoriensystem fuer die vorgelegten Vorbehalte.",
  kategorien = type_array(
    type_object(
      thema_id   = type_string("Kurz-ID in snake_case."),
      label      = type_string("Themenname, hoechstens fuenf Woerter."),
      definition = type_string("Was faellt hinein? Zwei bis drei Saetze."),
      abgrenzung = type_string("Was faellt NICHT hinein, besonders gegen das aehnlichste Thema.")
    ),
    "Die Themen des Systems, nach Haeufigkeit sortiert."
  )
)

b2_codebuch <- function(punkte, gegenstand = GEGENSTAND, n_max = N_THEMEN_MAX) {
  chat <- neuer_chat(str_glue("
    Du entwickelst das Kategoriensystem einer qualitativen Inhaltsanalyse zu \\
    Stellungnahmen. Begutachtungsgegenstand: {gegenstand}.

    - Hoechstens {n_max} Themen.
    - Trennscharf: jeder vorgelegte Vorbehalt passt in genau eines.
    - Erschoepfend: jeder Vorbehalt kommt unter. 'sonstiges' nur fuer echte Einzelfaelle.
    - Auf gleicher Abstraktionsebene. Nicht 'Rechtsstaatlichkeit' neben 'Frist in § 12'.
    - Sachlich benannt, nicht wertend.
  "), max_tokens = 32000)

  liste <- punkte |>
    distinct(kurztitel, .keep_all = TRUE) |>
    str_glue_data("- {kurztitel}: {beschreibung}") |>
    paste(collapse = "\n")

  erg <- chat$chat_structured(
    str_glue("
      {nrow(punkte)} Vorbehalte aus {n_distinct(punkte$doc_id)} Stellungnahmen, \\
      {n_distinct(punkte$kurztitel)} verschiedene Kurztitel.

      <vorbehalte>
      {liste}
      </vorbehalte>

      Entwickle daraus das Kategoriensystem.
    "),
    type = typ_codebuch
  )

  as_tibble(erg$kategorien) |> mutate(thema_nr = row_number(), .before = 1)
}

# --- D3  Deduktive Zuordnung ------------------------------------------------

# Hier wird "hoechstens zehn Themen" erst verbindlich: type_enum ueber die IDs
# des eingefrorenen Codebuchs. Das Modell kann strukturell nichts anderes ausgeben.
b3_zuordnen <- function(punkte, codebuch, gegenstand = GEGENSTAND) {
  typ <- type_object(
    thema_id  = type_enum(codebuch$thema_id, "Das eine Thema, das am besten passt."),
    konfidenz = type_enum(c("hoch", "mittel", "niedrig"),
                          "'niedrig', wenn zwei Themen gleich gut passen."),
    begruendung = type_string("Ein Satz, warum dieses und nicht das naechstaehnliche.")
  )

  chat <- neuer_chat(
    paste0(
      "Du ordnest Vorbehalte aus Stellungnahmen (Gegenstand: ", gegenstand,
      ") einem festen Kategoriensystem zu. Genau ein Thema je Vorbehalt. ",
      "Entscheide nach der Definition, nicht nach Wortaehnlichkeit zum Label. ",
      "Passen zwei gleich gut: das spezifischere, konfidenz 'niedrig'.\n\n",
      "<kategoriensystem>\n",
      codebuch |>
        str_glue_data("## {thema_id}\n{label}\nDefinition: {definition}\nAbgrenzung: {abgrenzung}") |>
        paste(collapse = "\n\n"),
      "\n</kategoriensystem>"
    ),
    effort = "low", max_tokens = 2000      # mechanische Entscheidung
  )

  erg <- parallel_chat_structured(
    chat,
    as.character(str_glue_data(punkte,
      "Kurztitel: {kurztitel}\nBeschreibung: {beschreibung}\nBezug: {bezug}\nZitat: \"{zitat}\"")),
    type = typ,
    on_error = "continue"
  )

  punkte |>
    bind_cols(as_tibble(erg)) |>
    left_join(select(codebuch, thema_id, label), by = "thema_id") |>
    pruefe_form("Variante B")
}


# === E  Auszaehlung (fuer beide Varianten dieselbe) ========================

# Zwei Zaehleinheiten, beide gehoeren berichtet:
#   n_nennungen - wie oft insgesamt vorgebracht (lange Stellungnahmen zaehlen mehrfach)
#   n_dokumente - in wie vielen Stellungnahmen ueberhaupt (meist die Zahl, die zaehlt)
haeufigkeiten <- function(nennungen, themen, korpus) {
  n_docs <- n_distinct(korpus$doc_id)

  themen |>
    select(thema_nr, thema_id, label) |>
    left_join(count(nennungen, thema_id, name = "n_nennungen"), by = "thema_id") |>
    left_join(nennungen |> distinct(doc_id, thema_id) |>
                count(thema_id, name = "n_dokumente"), by = "thema_id") |>
    mutate(
      across(c(n_nennungen, n_dokumente), \(x) coalesce(x, 0L)),
      anteil_dokumente = n_dokumente / n_docs,
      anteil_nennungen = n_nennungen / sum(n_nennungen)
    ) |>
    arrange(desc(n_dokumente), desc(n_nennungen))
}

dokument_thema_matrix <- function(nennungen, themen, korpus) {
  korpus |>
    select(doc_id, organisation) |>
    cross_join(select(themen, thema_id)) |>
    left_join(nennungen |> distinct(doc_id, thema_id) |> mutate(x = 1L),
              by = c("doc_id", "thema_id")) |>
    mutate(x = coalesce(x, 0L)) |>
    pivot_wider(names_from = thema_id, values_from = x)
}


# === F  Vergleich der beiden Varianten =====================================

# Die IDs unterscheiden sich, also baut ein Aufruf die Bruecke - type_enum
# hart auf die Gegenseite beschraenkt, "kein_gegenstueck" ausdruecklich erlaubt.
themen_abbilden <- function(themen_a, themen_b) {
  typ <- type_object(
    b_id = type_enum(c(themen_b$thema_id, "kein_gegenstueck"), "Entsprechung auf der Gegenseite."),
    aehnlichkeit = type_enum(c("identisch", "weitgehend", "teilweise", "kein_gegenstueck"),
                             "Wie gut decken sich die beiden Themen?")
  )
  chat <- neuer_chat(paste0(
    "Du gleichst zwei Kategoriensysteme derselben Inhaltsanalyse ab. Ordne jedem ",
    "vorgelegten Thema das inhaltlich entsprechende der Gegenseite zu. Gibt es ",
    "keines, waehle 'kein_gegenstueck' - lieber das als eine erzwungene Zuordnung.",
    "\n\n<gegenseite>\n",
    paste(themen_b$thema_id, themen_b$definition, sep = ": ", collapse = "\n"),
    "\n</gegenseite>"
  ), effort = "low", max_tokens = 1000)

  erg <- parallel_chat_structured(
    chat, as.character(str_glue_data(themen_a, "{thema_id}: {definition}")),
    type = typ, on_error = "continue")

  bind_cols(select(themen_a, a_id = thema_id, a_label = label), as_tibble(erg))
}

kennzahlen <- function(nenn_a, themen_a, nenn_b, themen_b, korpus) {
  zahl <- function(n, t) c(
    nrow(t), nrow(n), nrow(distinct(n, doc_id, thema_id)),
    median(count(n, doc_id)$n), sum(!korpus$doc_id %in% n$doc_id))
  tibble(
    kennzahl = c("Themen", "Nennungen gesamt", "Dokument-Thema-Paare",
                 "Nennungen je Dokument (Median)", "Dokumente ohne Treffer"),
    variante_a = zahl(nenn_a, themen_a),
    variante_b = zahl(nenn_b, themen_b)
  )
}

# Der eigentliche Test: jeder Vorbehalt, den B in einem Dokument gefunden hat,
# gegen das, was A fuer DASSELBE Dokument ausgibt.
abdeckung_pruefen <- function(punkte_b, nenn_a) {
  je_doc <- nenn_a |>
    group_by(doc_id) |>
    summarise(liste = paste0("- ", thema_id, ": \"", zitat, "\"", collapse = "\n"),
              .groups = "drop")

  aufgabe <- punkte_b |>
    left_join(je_doc, by = "doc_id") |>
    mutate(liste = coalesce(liste, "(keine Nennungen)"))

  typ <- type_object(
    abgedeckt = type_boolean("Kommt dieser Vorbehalt in der Liste der Gegenseite vor?"),
    thema_id = type_string("Wenn ja: welches Thema. Sonst 'keines'.")
  )
  chat <- neuer_chat(paste(
    "Du pruefst, ob ein Vorbehalt aus einer Stellungnahme in einer zweiten",
    "Auswertung derselben Stellungnahme vorkommt. Gleiche Sache, andere",
    "Formulierung zaehlt als abgedeckt. Ein bloss verwandtes Oberthema nicht."
  ), effort = "low", max_tokens = 1000)

  erg <- parallel_chat_structured(
    chat,
    as.character(str_glue_data(aufgabe,
      "Vorbehalt: {kurztitel} - {beschreibung}\nZitat: \"{zitat}\"\n\nGegenseite:\n{liste}")),
    type = typ, on_error = "continue")

  bind_cols(punkte_b, as_tibble(erg))
}

# Hypothese: was Variante A uebersieht, steht ueberproportional in der Mitte
# des zusammengesetzten Prompts. Das Belegzitat macht die Position ohne
# weiteren API-Aufruf messbar.
positionseffekt <- function(abdeckung, korpus) {
  abdeckung |>
    left_join(select(korpus, doc_id, rang, text, n_zeichen), by = "doc_id") |>
    mutate(
      treffer = map2_int(zitat, text, \(z, t) {
        m <- str_locate(t, fixed(str_sub(z, 1, 40)))
        if (is.na(m[1, 1])) NA_integer_ else as.integer(m[1, 1])
      }),
      pos_im_dokument = treffer / n_zeichen
    ) |>
    select(-text)
}


# === G  Guete ==============================================================

# Ohne diese Grundlinie sagt der Unterschied zwischen A und B nichts aus:
# Opus 5 nimmt kein temperature, zwei Laeufe sind nie identisch.
stabilitaet <- function(f_variante, laeufe = 2) {
  erg <- map(seq_len(laeufe), \(i) f_variante())
  paare <- combn(seq_along(erg), 2, simplify = FALSE)
  map_dfr(paare, \(p) {
    a <- distinct(erg[[p[1]]]$nennungen, doc_id, thema_id)
    b <- distinct(erg[[p[2]]]$nennungen, doc_id, thema_id)
    tibble(lauf_a = p[1], lauf_b = p[2],
           themen_a = nrow(erg[[p[1]]]$themen), themen_b = nrow(erg[[p[2]]]$themen),
           paare_a = nrow(a), paare_b = nrow(b),
           gemeinsam = nrow(inner_join(a, b, by = c("doc_id", "thema_id"))))
  })
}

# Der unverzichtbare Schritt: ~50 Nennungen selbst kodieren, ohne vorher auf
# die Maschinenkodierung zu schauen.
validierung_export <- function(nennungen, pfad, n = 50) {
  nennungen |>
    slice_sample(n = min(n, nrow(nennungen))) |>
    mutate(thema_maschine = thema_id, thema_manuell = NA_character_,
           anmerkung = NA_character_, .keep = "unused") |>
    write_csv(pfad)
  message("Validierungsstichprobe nach '", pfad, "'.")
  invisible(pfad)
}


# ===========================================================================
# ABLAUF - Block fuer Block
# ===========================================================================

stopifnot(nzchar(Sys.getenv("ANTHROPIC_API_KEY")))
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

korpus <- korpus_einlesen()
korpus |> select(doc_id, organisation, n_zeichen) |> print(n = Inf)
# Ein Dokument mit 300 Zeichen ist meist eine fehlgeschlagene PDF-Extraktion.

## --- Variante A: ein Aufruf ------------------------------------------------
a <- variante_a(korpus)
a$themen
a$dauer
haeufigkeiten(a$nennungen, a$themen, korpus) |> print(n = Inf)

## --- Variante B: mehrstufig ------------------------------------------------
abschnitte <- in_abschnitte_teilen(korpus)
punkte <- b1_offen_kodieren(abschnitte)
nrow(punkte); count(punkte, organisation, sort = TRUE)
# Zehn Zitate gegen das Original halten. Stimmen sie nicht woertlich,
# stimmt spaeter auch die Auszaehlung nicht.
punkte |> slice_sample(n = 10) |> select(organisation, kurztitel, zitat)

codebuch <- b2_codebuch(punkte)
write_csv(codebuch, file.path(OUT, "codebuch.csv"))

# >>> HALT: codebuch.csv oeffnen und pruefen <<<
#   ueberschneiden sich zwei Themen?   -> zusammenlegen / Abgrenzung schaerfen
#   fehlt ein fachlich zentrales?      -> ergaenzen
#   ist eines eine Haltung statt Thema -> umformulieren
# Danach eingefroren:
codebuch <- read_csv(file.path(OUT, "codebuch.csv"), show_col_types = FALSE)

b <- list(themen = codebuch, nennungen = b3_zuordnen(punkte, codebuch))
b$nennungen |> filter(konfidenz == "niedrig") |> select(kurztitel, label, begruendung)

tab <- haeufigkeiten(b$nennungen, b$themen, korpus)
print(tab, n = Inf)
write_csv(tab, file.path(OUT, "haeufigkeiten.csv"))
write_csv(dokument_thema_matrix(b$nennungen, b$themen, korpus),
          file.path(OUT, "dokument_thema_matrix.csv"))

## --- Vergleich -------------------------------------------------------------
# Zuerst die Grundlinie, sonst ist der Unterschied nicht interpretierbar:
stabilitaet(\() variante_a(korpus), laeufe = 2)

kennzahlen(a$nennungen, a$themen, b$nennungen, b$themen, korpus)
themen_abbilden(a$themen, b$themen)

abd <- abdeckung_pruefen(punkte, a$nennungen)
mean(abd$abgedeckt, na.rm = TRUE)          # Recall von A gegen B

pos <- positionseffekt(abd, korpus)
mean(!is.na(pos$treffer))                  # wie viele Zitate stehen woertlich im Text
pos |> group_by(rang, doc_id) |>
  summarise(n = n(), recall = mean(abgedeckt, na.rm = TRUE), .groups = "drop")
pos |> filter(!is.na(pos_im_dokument)) |>
  mutate(drittel = cut(pos_im_dokument, c(0, 1/3, 2/3, 1),
                       labels = c("Anfang", "Mitte", "Ende"), include.lowest = TRUE)) |>
  group_by(drittel) |> summarise(n = n(), recall = mean(abgedeckt, na.rm = TRUE))

## --- Validierung -----------------------------------------------------------
validierung_export(b$nennungen, file.path(OUT, "validierung.csv"), n = 50)
token_usage()
