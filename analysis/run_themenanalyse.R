# ---------------------------------------------------------------------------
# Ablauf der Themenanalyse - Schritt fuer Schritt ausfuehren, nicht am Stueck.
#
# Zwischen Stufe 2 und Stufe 3 liegt ein bewusster Halt: das Codebuch wird
# haendisch geprueft. Das ist der Schritt, der aus einer LLM-Spielerei eine
# nachvollziehbare Inhaltsanalyse macht.
#
# Voraussetzung: Sys.setenv(ANTHROPIC_API_KEY = "...") bzw. Eintrag in .Renviron
# ---------------------------------------------------------------------------

source("analysis/themenanalyse.R")

stopifnot(nzchar(Sys.getenv("ANTHROPIC_API_KEY")))

GEGENSTAND <- paste(
  "der Ministerialentwurf zur Einrichtung einer Bundesanwaltschaft",
  "(Weisungsspitze in Strafsachen anstelle des Bundesministers fuer Justiz)"
)
VERZEICHNIS <- "analysis/daten"      # hier liegen die Stellungnahmen als .txt
OUT <- "analysis/output"


# --- Stufe 0: Korpus --------------------------------------------------------

korpus <- korpus_einlesen(VERZEICHNIS, meta_datei = "analysis/daten/meta.csv")
abschnitte <- in_abschnitte_teilen(korpus)

korpus |> select(doc_id, organisation, n_zeichen) |> print(n = Inf)
# Kurz draufschauen: sind alle Dokumente vollstaendig eingelesen? Ein Dokument
# mit 300 Zeichen ist meist eine fehlgeschlagene PDF-Extraktion, kein kurzer Text.


# --- Stufe 1: induktive Offenkodierung --------------------------------------

punkte <- offen_kodieren(abschnitte, GEGENSTAND)

write_csv(punkte, file.path(OUT, "01_punkte.csv"))
nrow(punkte)
count(punkte, organisation, sort = TRUE)

# Plausibilitaet: zehn Punkte lesen und gegen die Originalstelle halten.
# Stimmen die Zitate woertlich? Wenn nicht, stimmt auch die Auszaehlung nicht.
punkte |> slice_sample(n = 10) |> select(organisation, kurztitel, zitat)


# --- Stufe 2: Kategorienbildung ---------------------------------------------

codebuch_roh <- codebuch_erzeugen(punkte, GEGENSTAND, n_min = 10, n_max = 18)
codebuch_schreiben(codebuch_roh, file.path(OUT, "02_codebuch.csv"))

# >>> HALT <<<
# Jetzt 02_codebuch.csv oeffnen und durchgehen:
#   - ueberschneiden sich zwei Kategorien? -> zusammenlegen oder Abgrenzung schaerfen
#   - fehlt ein Thema, das fachlich zentral ist? -> Kategorie ergaenzen
#   - ist eine Kategorie eine Haltung statt eines Themas? -> umformulieren
#   - sind die IDs sprechend und stabil? (sie landen als Spaltennamen in der Matrix)
# Erst danach weiterlaufen lassen. Das Codebuch ist ab hier eingefroren.

codebuch <- codebuch_lesen(file.path(OUT, "02_codebuch.csv"))


# --- Stufe 3: deduktive Zuordnung -------------------------------------------

zuordnungen <- punkte_zuordnen(punkte, codebuch, GEGENSTAND)
write_csv(zuordnungen, file.path(OUT, "03_zuordnungen.csv"))

# Wo die Maschine selbst unsicher war, lohnt der Blick:
zuordnungen |> filter(konfidenz == "niedrig") |> select(kurztitel, label, begruendung)


# --- Stufe 4: Haeufigkeiten -------------------------------------------------

tab_haeufigkeit <- haeufigkeiten(zuordnungen, codebuch, korpus)
tab_haltung <- haeufigkeiten_nach_stossrichtung(zuordnungen)
mat_dok_kat <- dokument_kategorie_matrix(zuordnungen, codebuch, korpus)

write_csv(tab_haeufigkeit, file.path(OUT, "04_haeufigkeiten.csv"))
write_csv(tab_haltung, file.path(OUT, "04_haltung.csv"))
write_csv(mat_dok_kat, file.path(OUT, "04_dokument_kategorie_matrix.csv"))

tab_haeufigkeit |>
  select(label, n_dokumente, anteil_dokumente, n_nennungen) |>
  print(n = Inf)


# --- Stufe 5: Guetepruefung -------------------------------------------------

rel <- reliabilitaet_pruefen(punkte, codebuch, GEGENSTAND, zuordnungen, n = 100)
rel$uebereinstimmung   # Ziel: >= 0.80
rel$kappa              # nur wenn Paket irr installiert
rel$abweichungen       # zeigt, welche Kategorienpaare sich beissen

goldstandard_export(zuordnungen, file.path(OUT, "05_validierung.csv"), n = 50)

token_usage()          # Kosten der Sitzung
