# Das Image ubuntu-server

Dies sind die Quellen für das Basis-Service-Image melservice/ubuntu-server

## Organisation der Daten im Image

Die benötigten Dateien werden in zwei Kategorien eingeteilt. Die Eingangsdateien werden benötigt, damit der Container arbeiten kann. Die Ausgangsdateien werden vom Dienst geschrieben und müssen nach Beendigung des Containers erhalten bleiben.

## Skripte

Der im Container laufende Dienst wird über ein Skript hochgefahren und auch beendet. Das Skript kopiert die Eingangsdateien aus dem Eingangsvolume an den korrekten Platz für den Service. Die vom Service geschriebenen Dateien werden dann beim Beenden in das Ausgabeverzeichnis kopiert, so dass sie beim nächsten Start eines Containers wieder zur Verfügung stehen.
