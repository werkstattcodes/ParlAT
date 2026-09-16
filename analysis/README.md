# Themenanalyse von Stellungnahmen (Begutachtungsverfahren)

LLM-gestützte qualitative Inhaltsanalyse von Stellungnahmen zu einem
Ministerialentwurf, mit `ellmer` und dem Tidyverse. Ergebnis sind
Häufigkeitstabellen darüber, welche Vorbehalte und Punkte über alle
Stellungnahmen hinweg wie oft vorgebracht wurden — jede Zahl bis zum
wörtlichen Zitat zurückverfolgbar.

Die Dateien gehören nicht zum Paket `ParlAT` (siehe `.Rbuildignore`); sie sind
ein eigenständiger Analyse-Workflow.

- `themenanalyse.R` — Funktionen
- `run_themenanalyse.R` — Ablauf, schrittweise auszuführen
- `daten/` — hier die Stellungnahmen als `.txt` ablegen (nicht versioniert)
- `output/` — Ergebnisse (nicht versioniert)

## Warum nicht einfach „lies alles und gib mir eine Tabelle“

Ein einzelner Prompt über alle Dokumente liefert eine Tabelle, die plausibel
aussieht und die niemand prüfen kann: Die Kategorien entstehen unterwegs, die
Zählung passiert im Modell, und es gibt keinen Weg von der Zahl zurück zum
Text. Für eine Aussage wie „14 von 31 Stellungnahmen kritisieren die
Ausgestaltung der Weisungsspitze“ ist das zu wenig.

Der Workflow zerlegt die Aufgabe deshalb in die vier Schritte der klassischen
qualitativen Inhaltsanalyse. Das Modell macht in jedem Schritt genau eine
kleine, prüfbare Sache; gezählt wird in R, nicht im Modell.

## Die fünf Stufen

**Stufe 1 — Induktive Offenkodierung.** Jede Stellungnahme (bei langen Texten:
jeder Abschnitt) wird einzeln durchgegangen. Das Modell extrahiert die
einzelnen Sachpunkte als strukturierte Objekte: Kurztitel, Beschreibung,
**wörtliches Belegzitat**, Bezug auf die Bestimmung, Stoßrichtung
(ablehnend / kritisch / Änderungsvorschlag / zustimmend / neutral).
Noch keine Kategorien — bewusst offen.

Das Belegzitat ist keine Zierde. Es ist die Bedingung dafür, dass später jede
Häufigkeit am Text überprüfbar ist, und es diszipliniert das Modell: Was sich
nicht zitieren lässt, darf nicht in die Liste.

**Stufe 2 — Kategorienbildung.** Alle extrahierten Kurztitel gehen in *einen*
Aufruf, der daraus ein Kategoriensystem entwickelt: 10–18 trennscharfe
Kategorien mit ID, Label, Definition, Abgrenzung und Ankerbeispielen. Nicht die
Volltexte, sondern die Punkte sind die Grundlage — das System soll aus dem
Material entstehen, nicht aus dem Rauschen.

Wichtig: Kategorien bilden ab, **worüber** gesprochen wird, nicht **mit welcher
Haltung**. Zustimmung und Ablehnung zum selben Thema gehören in dieselbe
Kategorie; die Haltung wird separat geführt und lässt sich später kreuztabellieren.

**Halt: menschliche Prüfung.** Das Codebuch wird als CSV geschrieben und
durchgesehen, bevor es weitergeht — überlappende Kategorien zusammenlegen,
fehlende ergänzen, Abgrenzungen schärfen. Danach ist es eingefroren. Dieser
Schritt ist der Unterschied zwischen einem nachvollziehbaren Kategoriensystem
und einem, das bei jedem Lauf anders aussieht.

**Stufe 3 — Deduktive Zuordnung.** Jeder Punkt wird einzeln gegen das
eingefrorene Codebuch kodiert. Die Kategorie-ID ist ein `type_enum` über genau
die IDs des Codebuchs: Das Modell *kann* strukturell nichts anderes ausgeben,
keine neue Kategorie erfinden und keine ID verändern. Dazu eine
Konfidenzangabe, die zeigt, wo zwei Kategorien gleich gut passten.

Hier entsteht die numerische Kategorisierung.

**Stufe 4 — Auszählung.** Reines `dplyr`. Zwei Zähleinheiten, die sich
unterscheiden und beide berichtet gehören:

- `n_nennungen` — wie oft wurde das Thema insgesamt vorgebracht. Eine sehr
  ausführliche Stellungnahme schlägt hier mehrfach durch.
- `n_dokumente` — in wie vielen Stellungnahmen kommt das Thema überhaupt vor.
  Robuster, und in der Regel die Zahl, die man berichten will („X von Y
  Stellungnahmen thematisieren …“).

Dazu die Kreuztabelle Kategorie × Stoßrichtung und die Dokument-×-Kategorie-
Matrix (0/1), die sich direkt weiterverarbeiten lässt.

**Stufe 5 — Gütekriterien.** Zwei Prüfungen:

- *Stabilität*: Stufe 3 läuft auf einer Stichprobe ein zweites Mal, die
  Übereinstimmung wird gemessen (und, wenn `irr` installiert ist, Cohens
  Kappa). Unter etwa 0,80 bedeutet: Codebuch nachschärfen, meist die Abgrenzung
  zwischen zwei Kategorien — nicht Ergebnisse berichten.
- *Validität*: ~50 Punkte werden als CSV exportiert und selbst kodiert, ohne
  vorher auf die Maschinenkodierung zu schauen. Erst dieser Abgleich sagt, ob
  die Kodierung nicht nur stabil, sondern auch richtig ist.

## Reproduzierbarkeit

`claude-opus-5` nimmt kein `temperature`/`top_p` mehr entgegen (die API
antwortet mit HTTP 400). Die Reproduzierbarkeit kommt hier deshalb nicht aus
`temperature = 0`, sondern aus drei anderen Quellen: dem eingefrorenen
Codebuch, der `type_enum`-Beschränkung in Stufe 3 und der gemessenen
Wiederholungsübereinstimmung aus Stufe 5. Praktisch trägt das weiter — die
Kategorien, aus denen gewählt wird, liegen fest und sind versioniert.

## Kosten und Laufzeit

`parallel_chat_structured()` schickt die Anfragen parallel (`max_active = 10`,
`rpm = 500`). Das Kategoriensystem steht in Stufe 3 im System-Prompt und wird
damit von Anthropic gecacht (`ellmer` setzt `cache = "5m"` per Default), was
bei mehreren hundert Zuordnungen deutlich spart. Wo Wartezeit egal ist, lässt
sich `parallel_chat_structured()` durch `batch_chat_structured(chat, prompts,
path = "...", type = ...)` ersetzen — die Batch-API kostet die Hälfte, braucht
aber bis zu 24 Stunden. `token_usage()` zeigt den Verbrauch der Sitzung.

## Voraussetzungen

```r
install.packages(c("ellmer", "tidyverse"))
install.packages("irr")   # optional, für Cohens Kappa
Sys.setenv(ANTHROPIC_API_KEY = "...")   # besser: ~/.Renviron
```

Die Stellungnahmen als `.txt` nach `analysis/daten/`. Für PDFs vorher
`pdftools::pdf_text()`, für Word `officer::read_docx() |> officer::docx_summary()`
— die Textextraktion gehört bewusst nicht in die Analyse-Pipeline. Optional
eine `analysis/daten/meta.csv` mit den Spalten `datei` und `organisation`,
damit die Tabellen sprechende Namen statt Dateinamen tragen.

## Test

```bash
Rscript --vanilla analysis/tests/test_themenanalyse.R
```

Prüft Einlesen, Abschnittsbildung, Entfaltung der Modellantworten und die
gesamte Auszählung gegen einen synthetischen Mini-Korpus. Die ellmer-Aufrufe
sind gestubbt — der Test braucht weder ellmer noch einen API-Key und sagt
nichts über die Qualität der Kodierung aus; dafür sind Stufe 5 und die
manuelle Validierung da.
