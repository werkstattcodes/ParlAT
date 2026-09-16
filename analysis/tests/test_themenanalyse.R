# ---------------------------------------------------------------------------
# Test der Analysefunktionen ohne API-Zugriff.
#
#   Rscript --vanilla analysis/tests/test_themenanalyse.R
#
# Die ellmer-Aufrufe werden gestubbt; geprueft wird alles drumherum -
# Einlesen, Abschnittsbildung, Entfaltung der Ergebnisse, Auszaehlung.
# Braucht nur dplyr/tidyr/purrr/stringr/tibble/readr, kein ellmer, keinen Key.
# ---------------------------------------------------------------------------

# ellmer muss fuer den Test nicht installiert sein -> library() maskieren
library <- function(...) invisible(NULL)
hier <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(hier) || !nzchar(hier)) hier <- "analysis/tests"
source(file.path(hier, "..", "themenanalyse.R"))
rm(library)
suppressPackageStartupMessages({
  base::library(dplyr); base::library(tidyr); base::library(purrr)
  base::library(stringr); base::library(tibble); base::library(readr)
})

params <- function(...) list(...)
chat_anthropic <- function(...) structure(list(...), class = "stub_chat")
type_object <- function(...) list(...)
type_array <- function(...) list(...)
type_enum <- function(values, ...) list(values = values)
type_string <- function(...) "string"

n_ok <- 0L; n_fail <- 0L
ok <- function(bed, txt) {
  bestanden <- isTRUE(bed)
  if (bestanden) n_ok <<- n_ok + 1L else n_fail <<- n_fail + 1L
  cat(if (bestanden) "  OK   " else "  FAIL ", txt, "\n")
}


# --- Fixtures ---------------------------------------------------------------
tmp <- file.path(tempdir(), "stn"); dir.create(tmp, showWarnings = FALSE)
schreib <- function(name, ...) writeLines(c(...), file.path(tmp, name))
schreib("a.txt",
  "Stellungnahme des Beispielverbands", "",
  "Sehr geehrte Damen und Herren, wir danken fuer die Uebermittlung.", "",
  "Zu Paragraf 4 Abs. 2: Die Ausgestaltung der Weisungsspitze als Einzelorgan",
  "wird abgelehnt. Ein Dreiersenat waere vorzuziehen.", "",
  "Zur Bestellung: Das Bestellverfahren ist intransparent ausgestaltet.", "",
  "Die budgetaere Ausstattung der neuen Behoerde bleibt offen.")
schreib("b.txt",
  "Stellungnahme der Beispielvereinigung", "",
  "Die Einrichtung einer weisungsfreien Bundesanwaltschaft wird begruesst.", "",
  "Kritisch sehen wir die Berichtspflichten; die Frist ist zu kurz bemessen.", "",
  "Auch die Ressourcenfrage ist ungeloest.")
schreib("c.txt",
  "Stellungnahme der Beispielkammer", "",
  "Zur Weisungsspitze: Die Konzentration der Befugnisse begegnet Bedenken.", "",
  "Das Bestellverfahren sollte einen Parlamentsvorbehalt vorsehen.")
writeLines(c("datei,organisation", "a.txt,Beispielverband",
             "b.txt,Beispielvereinigung", "c.txt,Beispielkammer"),
           file.path(tmp, "meta.csv"))

cat("\n== Stufe 0: Korpus ==\n")
korpus <- korpus_einlesen(tmp, meta_datei = file.path(tmp, "meta.csv"))
ok(nrow(korpus) == 3, "drei Dokumente eingelesen")
ok(all(korpus$doc_id == c("D001","D002","D003")), "doc_id vergeben")
ok(all(str_detect(korpus$text, "\n\n")), "Absatzgrenzen ueberlebt die Normalisierung")
ok(!any(str_detect(korpus$text, "  ")), "doppelte Leerzeichen entfernt")
ok(identical(sort(korpus$organisation),
             sort(c("Beispielverband","Beispielvereinigung","Beispielkammer"))),
   "Metadaten gejoint")

cat("\n== Stufe 0: Abschnitte ==\n")
absch <- in_abschnitte_teilen(korpus, max_zeichen = 250)
ok(nrow(absch) > nrow(korpus), "lange Dokumente werden geteilt")
ok(all(str_detect(absch$abschnitt_id, "^D\\d{3}-\\d{2}$")), "abschnitt_id Format")
zeichen_vorher <- sum(nchar(str_remove_all(korpus$text, "\\s")))
zeichen_nachher <- sum(nchar(str_remove_all(absch$text, "\\s")))
ok(zeichen_vorher == zeichen_nachher, "kein Textverlust beim Teilen")
ok(all(!is.na(absch$organisation)), "organisation durchgereicht")
ganz <- in_abschnitte_teilen(korpus, max_zeichen = 40000)
ok(nrow(ganz) == 3, "kurze Dokumente bleiben ungeteilt")

cat("\n== Stufe 1: Nachbearbeitung der Offenkodierung ==\n")
mach_punkte <- function(n, titel) {
  tibble(kurztitel = titel, beschreibung = paste("Beschreibung", titel),
         zitat = paste("Zitat", titel), bezug = "allgemein",
         stossrichtung = rep(c("kritisch","ablehnend"), length.out = n))
}
parallel_chat_structured <- function(chat, prompts, type, ...) {
  tibble(punkte = list(mach_punkte(2, c("Weisungsspitze","Bestellverfahren")),
                       mach_punkte(1, "Ressourcen"),
                       tibble()))
}
absch3 <- head(absch, 3)
punkte <- offen_kodieren(absch3, "Testgegenstand")
ok(nrow(punkte) == 3, "leere Ergebnisse gefiltert, Rest entfaltet")
ok(all(punkte$punkt_id == c("P0001","P0002","P0003")), "punkt_id fortlaufend")
ok(all(c("doc_id","organisation","zitat","stossrichtung") %in% names(punkte)),
   "Dokumentkontext bleibt an den Punkten haengen")

cat("\n== Stufe 3: Zuordnung ==\n")
punkte <- tibble(
  punkt_id = sprintf("P%04d", 1:7),
  doc_id   = c("D001","D001","D001","D002","D002","D003","D003"),
  organisation = c(rep("A",3), rep("B",2), rep("C",2)),
  kurztitel = c("Weisungsspitze","Bestellverfahren","Budget","Berichtspflicht",
                "Ressourcen","Weisungsspitze","Bestellverfahren"),
  beschreibung = "x", zitat = "y", bezug = "allgemein",
  stossrichtung = c("ablehnend","kritisch","kritisch","kritisch",
                    "kritisch","ablehnend","aenderungsvorschlag"))
codebuch <- tibble(
  kategorie_nr = 1:4,
  kategorie_id = c("weisungsspitze","bestellverfahren","ressourcen","berichtspflichten"),
  label = c("Weisungsspitze","Bestellverfahren","Ressourcen","Berichtspflichten"),
  definition = "d", abgrenzung = "a", ankerbeispiele = "b")
zuw <- c("weisungsspitze","bestellverfahren","ressourcen","berichtspflichten",
         "ressourcen","weisungsspitze","bestellverfahren")
parallel_chat_structured <- function(chat, prompts, type, ...) {
  ok(length(prompts) == 7, "ein Prompt je Punkt")
  ok(identical(type$kategorie_id$values, codebuch$kategorie_id),
     "type_enum auf die Codebuch-IDs beschraenkt")
  tibble(kategorie_id = zuw, konfidenz = "hoch", begruendung = "weil")
}
zuordnungen <- punkte_zuordnen(punkte, codebuch, "Testgegenstand")
ok(nrow(zuordnungen) == 7 && all(!is.na(zuordnungen$label)), "Labels gejoint")

cat("\n== Stufe 4: Haeufigkeiten ==\n")
korpus4 <- tibble(doc_id = c("D001","D002","D003"), organisation = c("A","B","C"))
tab <- haeufigkeiten(zuordnungen, codebuch, korpus4)
ok(nrow(tab) == 4, "alle Kategorien in der Tabelle, auch die leeren")
ok(tab$n_nennungen[tab$kategorie_id == "weisungsspitze"] == 2, "Nennungen gezaehlt")
ok(tab$n_dokumente[tab$kategorie_id == "weisungsspitze"] == 2, "Dokumente gezaehlt")
ok(tab$n_nennungen[tab$kategorie_id == "ressourcen"] == 2 &&
   tab$n_dokumente[tab$kategorie_id == "ressourcen"] == 2,
   "Nennungen vs. Dokumente korrekt getrennt")
ok(abs(sum(tab$anteil_nennungen) - 1) < 1e-9, "Anteile der Nennungen summieren auf 1")
ok(all(tab$anteil_dokumente <= 1), "Dokumentanteile <= 1")
ok(all(diff(tab$n_dokumente) <= 0), "absteigend sortiert")

haltung <- haeufigkeiten_nach_stossrichtung(zuordnungen)
ok(sum(haltung$gesamt) == 7, "Kreuztabelle summiert auf alle Punkte")
ok(!"gesamt" %in% c("kategorie_id","label"), "gesamt separat")

mat <- dokument_kategorie_matrix(zuordnungen, codebuch, korpus4)
ok(nrow(mat) == 3, "eine Zeile je Dokument")
ok(all(codebuch$kategorie_id %in% names(mat)), "eine Spalte je Kategorie")
ok(sum(as.matrix(mat[, codebuch$kategorie_id])) == 7, "sieben Dokument-Kategorie-Paare")
ok(all(as.matrix(mat[, codebuch$kategorie_id]) %in% c(0L,1L)), "nur 0/1")
print(mat)

cat("\n== Stufe 5 ==\n")
zuordnungen2 <- zuordnungen |> mutate(kategorie_id = replace(kategorie_id, 3, "ressourcen"))
parallel_chat_structured <- function(chat, prompts, type, ...)
  tibble(kategorie_id = zuw[seq_along(prompts)], konfidenz = "hoch", begruendung = "b")
rel <- reliabilitaet_pruefen(punkte, codebuch, "T", zuordnungen, n = 7)
ok(is.numeric(rel$uebereinstimmung) && rel$uebereinstimmung >= 0,
   "Uebereinstimmung berechnet")
p <- goldstandard_export(zuordnungen, file.path(tmp, "gold.csv"), n = 5)
g <- read_csv(p, show_col_types = FALSE)
ok(nrow(g) == 5 && all(is.na(g$kategorie_manuell)), "Validierungsstichprobe exportiert")
cat(sprintf("\n%d Pruefungen, %d Fehlschlaege\n", n_ok + n_fail, n_fail))
if (n_fail > 0) quit(status = 1)
