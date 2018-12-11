#!/bin/bash
#
# die Übergebenen Pakete per apt-get installieren und das Image wieder aufräumen

packages="$*";
apt-get install -y --no-install-recommends ${packages} \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/* /var/lib/dpkg/info/*
