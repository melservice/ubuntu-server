#!/bin/bash
#
# die Übergebenen Pakete per apt-get installieren und das Image wieder aufräumen

packages="$*";
apt-get update --fix-missing -y \
	&& apt-get dist-upgrade --fix-missing -y \
	&& apt-get install --fix-missing -y --no-install-recommends ${packages} \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*
