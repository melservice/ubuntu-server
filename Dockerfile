FROM ubuntu:18.04

LABEL version="1.0" \
	description="Basis-Server auf Ubuntu-Basis" \
	maintainer="develop@melsaesser.de"

# Verzeichnis für die Initialisierung des Images sowie Input und Output erstellen
RUN mkdir -p /docker/init/ \
	&& mkdir -p /docker/input \
	&& mkdir -p /docker/output

# Die bereitgestellten Skripte und Einstellungen kopieren
ADD scripts/ /docker/init/

# Die aktuellen Paketlisten laden, Updates holen und Initialisierung laufen lassen,
# danach wird wieder aufgeräumt
RUN apt-get update \
	&& apt-get -y dist-upgrade \
	&& /docker/init/aptInstall.sh apt-utils bash

# Dies ist das Start-Kommando
CMD ["bash"]
