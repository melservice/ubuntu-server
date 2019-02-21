#!/bin/bash
#
# Library von Martin Elsässer für die Skriptereien
# ==========================================================================================================

if [ "$0" != "-bash" -a "$0" != "-su" ]; then
	SCRIPT_DIR=$(readlink -f $(dirname "$0"));
else
	SCRIPT_DIR="/root";
fi;

# ----------------------------------------------------------------------------------------------------------
#
# Prüfen, ob ein Server/Client erreichbar ist
# 
# Parameter:
#    1: Name des Servers/Clients oder die IP-Adresse
#
# Ergebnis:
#    $rc: =0 (nicht erreichbar) / =1 (erreichbar)
#
# ----------------------------------------------------------------------------------------------------------

function isPingable {
	local name=$1;
	ping -c 1 ${name} 2>/dev/null >/dev/null;
	if [ $? -eq 0 ]; then
		rc=1;
	else
		rc=0;
	fi;

	return ${rc};
}

# ----------------------------------------------------------------------------------------------------------
#
# Kurz prüfen, ob das Verzeichnis existert - ggf. muss dann das Verzeichnis erst gemountet werden
#
# Parameter:
#    1: MountPoint, der geprüft und ggf. gemountet werden soll
#
# Ergebnis:
#    $rc: =1 (MountPoint ist gemountet) / =0 (MountPoint konnte nicht gemountet werden, nicht erreichbar)
#
# ----------------------------------------------------------------------------------------------------------

function checkAndMountDir {
	local dirName=$1;
	rc=1;
	grep "${dirName}" /etc/mtab 2>/dev/null 1>/dev/null;
	if [ $? -ne 0 ]; then
		mount "${dirName}" 2>/dev/null 1>/dev/null;
		grep "${dirName}" /etc/mtab 2>/dev/null 1>/dev/null;
		if [ $? -ne 0 ]; then
			rc=0;
		fi;
	fi;

	return ${rc};
}