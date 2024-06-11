FROM ubuntu:latest
LABEL version="1.0" \
	description="Basis-Service auf Ubuntu-Basis für weitere Docker basierte Services" \
	maintainer="develop@melsaesser.de"

# Die bereitgestellten Skripte und Einstellungen kopieren
COPY rootfs /

# Die aktuellen Paketlisten laden, Updates holen und Initialisierung laufen lassen,
# danach wird wieder aufgeräumt
RUN find /docker/ -type f -name "*.sh" -exec chmod 755 "{}" \; \
	&& /docker/init/aptInstall.sh apt-utils bash sudo openssl ca-certificates locales git \
	&& /docker/init/create-ubuntu-server.sh

ENV LANG de_DE.UTF-8

# Dies ist das Start-Kommando
#ENTRYPOINT ["bash"]
