# Themenanalyse von Stellungnahmen (Begutachtungsverfahren)

LLM-gestützte qualitative Inhaltsanalyse von Stellungnahmen zu einem
Ministerialentwurf, mit `ellmer` und dem Tidyverse. Ergebnis sind
Häufigkeitstabellen darüber, welche Vorbehalte über alle Stellungnahmen
hinweg wie oft vorgebracht wurden — jede Zahl bis zum wörtlichen Zitat
zurückverfolgbar.

Alles steckt in einer Datei: **`themenanalyse_komplett.R`**. Sie gehört nicht
zum Paket `ParlAT` (siehe `.Rbuildignore`), sondern ist ein eigenständiger
Analyse-Workflow. Block für Block ausführen, nicht am Stück sourcen — zwischen
D2 und D3 liegt ein Halt.

- `daten/` — hier die Stellungnahmen als `.txt` ablegen (nicht versioniert)
- `output/` — Ergebnisse (nicht versioniert)

## Zwei Wege zur selben Frage

Das Skript enthält beide, weil der Vergleich selbst aufschlussreich ist.

**Variante A (Abschnitt C) — ein einziger Aufruf.** Alle Stellungnahmen wandern
in einen Prompt; das Modell gibt direkt bis zu zehn Themen mit ihren Nennungen
zurück. Möglich, weil Opus 5 ein Kontextfenster von 1 Mio. Tokens hat. Schnell,
billig, zwanzig Zeilen.

**Variante B (Abschnitt D) — mehrstufig.** Erst pro Dokument die einzelnen
Vorbehalte extrahieren, dann daraus ein Kategoriensystem bilden, das prüfen und
einfrieren, dann jeden Vorbehalt dagegen kodieren.

Beide liefern **dieselbe Ergebnisform**:

```r
NENNUNG_SPALTEN <- c("doc_id", "organisation", "thema_id", "label", "zitat")
```

Deshalb existieren Auszählung (E) und Vergleich (F) nur einmal, und ein
Unterschied zwischen den Varianten kann nicht aus unterschiedlichem Zählcode
stammen.

## Warum die mehrstufige Variante

Ein einzelner Prompt über alle Dokumente liefert eine Tabelle, die plausibel
aussieht und die niemand prüfen kann: Kategorien entstehen unterwegs, gezählt
wird im Modell, und es gibt keinen Weg von der Zahl zurück zum Text. Für eine
Aussage wie „14 von 31 Stellungnahmen kritisieren die Weisungsspitze" ist das
zu wenig.

Variante B zerlegt die Aufgabe deshalb in die Schritte der klassischen
qualitativen Inhaltsanalyse. Das Modell macht pro Schritt eine kleine, prüfbare
Sache; gezählt wird in `dplyr`.

**D1 — Induktive Offenkodierung.** Jedes Dokument (bei langen Texten: jeder
Abschnitt) einzeln. Das Modell extrahiert die Vorbehalte als strukturierte
Objekte: Kurztitel, Beschreibung, **wörtliches Belegzitat**, betroffene
Bestimmung. Noch keine Kategorien.

Das Belegzitat ist keine Zierde. Es ist die Bedingung dafür, dass jede
Häufigkeit später am Text überprüfbar ist, es diszipliniert das Modell (was
sich nicht zitieren lässt, darf nicht in die Liste), und es macht in Abschnitt F
den Positionseffekt ohne weiteren API-Aufruf messbar.

**D2 — Kategorienbildung.** Alle Kurztitel gehen in *einen* Aufruf, der daraus
höchstens zehn trennscharfe Themen entwickelt. Grundlage sind die extrahierten
Punkte, nicht die Volltexte — so hat ein Vorbehalt im Nebensatz dasselbe
Gewicht wie einer, der über drei Seiten ausgebreitet wird.

Themen bilden ab, **worüber** gesprochen wird, nicht **mit welcher Haltung**.

**Halt: menschliche Prüfung.** Das Codebuch wird als CSV geschrieben und
durchgesehen, bevor es weitergeht. Danach ist es eingefroren. Dieser Schritt
ist der Unterschied zwischen einem nachvollziehbaren Kategoriensystem und
einem, das bei jedem Lauf anders aussieht.

**D3 — Deduktive Zuordnung.** Jeder Vorbehalt einzeln gegen das eingefrorene
Codebuch. Die Themen-ID ist ein `type_enum` über genau dessen IDs: Das Modell
*kann* strukturell nichts anderes ausgeben. Hier wird „höchstens zehn Themen"
erst verbindlich.

**E — Auszählung.** Reines `dplyr`. Zwei Zähleinheiten, beide gehören berichtet:

- `n_nennungen` — wie oft insgesamt vorgebracht. Eine ausführliche
  Stellungnahme schlägt mehrfach durch.
- `n_dokumente` — in wie vielen Stellungnahmen das Thema überhaupt vorkommt.
  Robuster, und meist die Zahl, die man berichten will.

Dazu die Dokument-×-Thema-Matrix (0/1).

## Vergleich der Varianten (Abschnitt F)

Die Erwartung „da muss doch dasselbe rauskommen" lässt sich prüfen statt
behaupten. Die Reihenfolge ist entscheidend: **zuerst** messen, wie stark eine
Variante mit sich selbst schwankt (`stabilitaet()`), **dann** den Unterschied
zwischen den Varianten. Ohne diese Grundlinie könnte jede Differenz reines
Modellrauschen sein.

- `kennzahlen()` — Themen, Nennungen, Dokument-Thema-Paare, Dokumente ohne Treffer
- `themen_abbilden()` — die IDs unterscheiden sich; ein Aufruf baut die Brücke,
  `type_enum` hart auf die Gegenseite beschränkt, `"kein_gegenstueck"` erlaubt
- `abdeckung_pruefen()` — Recall: Kommt jeder Vorbehalt aus B auch in A vor,
  für dasselbe Dokument?
- `positionseffekt()` — Hypothese „lost in the middle": Steht das Übersehene
  überproportional in der Mitte des zusammengesetzten Prompts? Nebenbefund
  gratis: wie viele „wörtliche" Zitate stehen tatsächlich wörtlich im Text.

Der Vergleich benutzt selbst ein Modell (Themenabbildung, Abdeckungsprüfung).
Die Urteile sind also auch verrauscht und gehören stichprobenartig nachgeprüft,
sonst misst man am Ende den Schiedsrichter.

## Ein praktischer Fallstrick

In Variante A **tippt das Modell die Organisationsnamen ab**. Schreibt es
„Alpha GmbH", wo im Dokument „Alpha" steht, fällt die Nennung beim Join lautlos
heraus und die Häufigkeit ist zu niedrig. `variante_a()` warnt deshalb über
Nennungen mit unbekannter Organisation.

In Variante B kann das nicht passieren: Dort kommt die Zuordnung
Dokument → Nennung aus dem Prompt-Aufbau, nicht aus der Antwort.

## Selbsttest (Abschnitt H)

```bash
Rscript --vanilla analysis/themenanalyse_komplett.R --test
```

Prüft alles außer den API-Aufrufen selbst: Einlesen, Abschnittsbildung, beide
Varianten bis zur gemeinsamen Ergebnisform, die Auszählung über beide, die
Vergleichs- und die Gütefunktionen. Die ellmer-Aufrufe sind durch Attrappen
ersetzt — der Test braucht weder `ellmer` noch einen API-Key. Exit-Code 0 bei
Erfolg, 1 bei Fehlschlag. 33 Prüfungen.

Was der Test *nicht* sagt: ob die Kodierung inhaltlich gut ist. Dafür sind
Abschnitt G und die manuelle Validierung da.

## Gütekriterien (Abschnitt G)

- *Stabilität*: eine Variante zweimal laufen lassen, Übereinstimmung messen.
- *Validität*: `validierung_export()` zieht ~50 Nennungen als CSV. Die kodierst
  du selbst, ohne vorher auf die Maschinenkodierung zu schauen. Erst dieser
  Abgleich sagt, ob die Kodierung nicht nur stabil, sondern auch richtig ist.

## Reproduzierbarkeit

`claude-opus-5` nimmt kein `temperature`/`top_p` mehr entgegen (die API
antwortet mit HTTP 400). Reproduzierbarkeit kommt hier deshalb aus dem
eingefrorenen Codebuch, der `type_enum`-Beschränkung in D3 und der gemessenen
Wiederholungsübereinstimmung — nicht aus `temperature = 0`.

## Kosten und Laufzeit

`parallel_chat_structured()` schickt parallel (`max_active = 10`, `rpm = 500`).
`ellmer` setzt `cache_control` auf den System-Prompt und den letzten
Content-Block, wiederholte Läufe treffen also den Prompt-Cache. Wo Wartezeit
egal ist, lässt sich `parallel_chat_structured()` durch `batch_chat_structured(
chat, prompts, path = "...", type = ...)` ersetzen — halber Preis, bis zu 24
Stunden Laufzeit. `token_usage()` zeigt den Verbrauch der Sitzung.

Variante A ist deutlich billiger: ein Aufruf statt vieler, und der Input ist
fast derselbe, weil jedes Dokument so oder so einmal gelesen wird.

## Voraussetzungen

```r
install.packages(c("ellmer", "tidyverse"))
Sys.setenv(ANTHROPIC_API_KEY = "...")   # besser: ~/.Renviron
```

Stellungnahmen als `.txt` nach `analysis/daten/`. Für PDFs vorher
`pdftools::pdf_text()`, für Word `officer::read_docx() |> officer::docx_summary()`
— die Textextraktion gehört bewusst nicht in die Analyse-Pipeline. Optional
eine `analysis/daten/meta.csv` mit den Spalten `datei` und `organisation`,
damit die Tabellen sprechende Namen statt Dateinamen tragen.
