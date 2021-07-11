FROM ubuntu:latest
LABEL version="1.0" \
	description="Basis-Service auf Ubuntu-Basis für weitere Docker basierte Services" \
	maintainer="develop@melsaesser.de"

# Die bereitgestellten Skripte und Einstellungen kopieren
COPY rootfs /

# Die aktuellen Paketlisten laden, Updates holen und Initialisierung laufen lassen,
# danach wird wieder aufgeräumt
RUN apt-get update --fix-missing -y \
	&& apt-get dist-upgrade --fix-missing -y \
	&& /docker/init/aptInstall.sh apt-utils bash sudo openssl locales git \
	&& /docker/init/create-ubuntu-server.sh

ENV LANG de_DE.UTF-8

# Dies ist das Start-Kommando
#ENTRYPOINT ["bash"]
