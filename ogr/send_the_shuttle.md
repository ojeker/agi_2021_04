# Wir schicken den Bus

## Hintergrund

Dank erfolgten Investitionen in den letzten vier Jahren können INTERLIS Transferdateien nun gut mit [ili2db](https://www.interlis.ch/downloads/ili2db)
in gängige GIS-Datenhaltungen umgewandelt werden (PostGIS, Geopackage, ESRI FGDB).

Wir vom [AGI Solothurn](https://so.ch/verwaltung/bau-und-justizdepartement/amt-fuer-geoinformation/) haben insbesondere Erfahrungen mit PostGIS. Im Zusammenhang mit Aufträgen an externe Büros
stellt sich die Frage, welche Varianten sich für die Schnittstelle zwischen einer GDI und der GIS-Arbeit im Büro
gut eignen.

In der GDI des Kantons Solothurn pflegen wir die Datenschema sehr bewusst und sorgfältig, damit die Datenflüsse, 
Konfigurationen etc. stabil sind und eine gute Service-Qualität im Betrieb gewährleistet werden kann. 
Die Daten werden konsequent mit INTERLIS-Modellen beschrieben.

Im Rahmen eines Auftrages wird im Büro häufig iterativ mit Trial / Error gearbeitet, um schrittweise das gewünschte Resultat
zu erarbeiten. Im Verlauf der Erarbeitung werden die Daten also tüchtig "durchgeknetet". Das "Durchkneten" darf
nicht direkt auf einer mit ili2db generierten Datei erfolgen. Die Gefahr wäre zu gross, dass die für ili2db 
zentralen Metainformationen verloren gehen.

## Lösungsansatz

Was also tun? In diesem Proof of Concept (POC) wird die folgende Idee konkretisiert:
* Das AGI schickt dem Büro einen mit ili2db generierten leeren Datencontainer.
* Das Büro 
    * füllt die erarbeiteten Daten in den Datencontainer ein.
    * stellt sicher, dass die Daten im befüllten Datencontainer modellkonform sind
    * schickt die Daten im Datencontainer an das AGI zurück
* Das AGI liest die modellkonformen Daten in die GDI ein.

Bildlich gesprochen schickt das AGI dem Büro den Bus (den Datencontainer). Im Büro steigen die Features von der 
Datenhaltung des Büros in den Datencontainer um. **Zentral dabei ist, dass beim Umsteigevorgang die Struktur des 
Datencontainers nicht verändert wird.** Dass also nur Zeilen in die vordefinierten Tabellen des Containers eingefüllt 
werden, und nicht die Tabellendefinitionen selbst modifiziert werden.

##  Proof of Concept

Im POC wird ermittelt, ob und wie das Einfüllen in den Datencontainer mit [ogr2ogr](https://gdal.org/programs/ogr2ogr.html) vom Büro gemacht werden kann.

Um das Ganze so richtig knackig zu machen, gehen wir von der Verwendung des **Grosi aller breit verwendeten GIS-Formate** 
aus. Ja richtig - die Software unseres Büros verwendet das ca. 1992 erfundene Shapefile.

### -sql to the rescue

In den ogr-tools gibt es die Option -sql, mit welcher eine Teilmenge des SQL-92 Standart genutzt werden kann. 
Wird die Teilmenge für unsere Zwecke genügen?

Ein erstes Beispiel stimmt mich positiv:

Eingabe:

```
ogrinfo -sql '
    select 
        cast (t_id as integer), 
        identifika as identifikator,
        bemerkunge as bemerkungen, 
        cast(istaltrech as boolean) as istaltrechtlich,
        cast(erhoben as timestamp)
    from 
        areas as areas_append
' -geom=NO ./shpsource/
```
Ausgabe (letztes Feature):

```
OGRFeature(areas_append):6
  t_id (Integer) = 46816
  identifikator (String) = (null)
  bemerkungen (String) = Altdaten-FID: 4743-1
  istaltrechtlich (Integer(Boolean)) = 0
  erhoben (DateTime) = 2020/04/30 06:26:57
```

`istaltrechtlich (Integer(Boolean)) = 0` sieht einigermassen abenteuerlich aus, aber mit:
* `as` werde ich die Attributlängen-Limitation wieder los.
* `cast(erhoben as timestamp)` kann ich sogar einen String in einen Timestamp "hochwandeln".
* `areas as areas_append` benenne ich die Tabelle um

### Einfüllen - DDL verboten

Kann ich mit ogr2ogr die Daten in die bestehende Tabelle des Datencontainers einfüllen? In "SQL-Jargon": Ohne
Nutzung von SQL DDL Statements a la `create table ...`?

```
ogr2ogr -sql '
    select 
        cast (t_id as integer), 
        identifika as identifikator,
        bemerkunge as bemerkungen, 
        cast(istaltrech as boolean) as istaltrechtlich,
        cast(erhoben as timestamp)
    from 
        areas as areas_append
' -update -append -f GPKG output.gpkg ./shpsource/
```

Wichtig sind die Flags `-update -append`. Damit wird sichergestellt, dass mit inserts in die bestehende leere Tabelle
eingefüllt wird.

Nach **zweimaligem** Durchführen sollten 14 Features in der Tabelle "areas_append" enthalten sein (und nicht zwei 
Tabellen areas_append und areas_append_1!).

Der Folgende Befehl schafft Klarheit:

```
ogrinfo -sql '
    select 
        t_id
        identifikator,
        bemerkungen, 
        istaltrechtlich,
        erhoben
    from 
        areas_append
' -geom=NO output.gpkg
```

Resultat (letztes Feature):

```
OGRFeature(SELECT):13
  identifikator (String) = 46816.0
  bemerkungen (String) = Altdaten-FID: 4743-1
  istaltrechtlich (Integer) = 0
  erhoben (DateTime) = 2020/04/30 06:26:57+00
```

Es sind also 14 Features enthalten. Hat bestens geklappt!

## Fazit

"Wir schicken den Bus" (den Datencontainer) hat Potential. Das kopieren der Features von Shape in Geopackage hat
gleich auf anhieb funktioniert.

Um das massiv ressourcenfressende hin und her von noch nicht guten Daten zu minimieren, wäre es für ein Büro 
eine gute Dienstleistung, mit Onlinedienst direkt den Geopackage Datencontainer auf Modellkonformität prüfen 
zu können.



  


  
