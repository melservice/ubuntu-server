#!/bin/bash
#
# Library von Martin Elsässer für die Skriptereien
# ==========================================================================================================

# Das Skript läuft ggf. nur als in EXEC_USER definierter User
if [ ! -z "$EXEC_USER" ] && [ $(id -un) != "$EXEC_USER" ]; then
	echo "Start als User '$(id -un)' -> Skript-Restart als User '$EXEC_USER'";
	sudo -u $EXEC_USER "$0" $*;
	exit $?
fi;

# ----------------------------------------------------------------------------------------------------------

if [ "$0" != "-bash" -a "$0" != "-su" ]; then
	SCRIPT_DIR=$(readlink -f $(dirname "$0"));
else
	SCRIPT_DIR="/root";
fi;

# ---------------------------------------------------------------------------------------------------

set -o pipefail

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
# Das Verzeichnis und das Mount-Ziel muss in der /etc/fstab stehen
#
# Parameter:
#    1: MountPoint, der geprüft und ggf. gemountet werden soll
#
# Ergebnis:
#    $rc: =1 (MountPoint ist gemountet) / =0 (MountPoint konnte nicht gemountet werden, nicht erreichbar)
#
# ----------------------------------------------------------------------------------------------------------

function checkAndMountDir {
	local _dirName="$1";
	rc=1;
	grep "${_dirName}" /etc/mtab 2>/dev/null 1>/dev/null;
	if [ $? -ne 0 ]; then
		mount "${_dirName}" 2>/dev/null 1>/dev/null;
		grep "${_dirName}" /etc/mtab 2>/dev/null 1>/dev/null;
		if [ $? -ne 0 ]; then
			rc=0;
		fi;
	fi;

	return ${rc};
}

# ----------------------------------------------------------------------------------------------------------
#
# Kurz prüfen, ob das Verzeichnis existert - ggf. muss dann das Verzeichnis erst gemountet werden
# Das zu mountende Verzeichnis muss nicht in der /etc/fstab stehen, sondern das Ziel wird übergeben
#
# Parameter:
#    1: MountPoint, der geprüft und ggf. gemountet werden soll
#
# Ergebnis:
#    $rc: =1 (MountPoint ist gemountet) / =0 (MountPoint konnte nicht gemountet werden, nicht erreichbar)
#
# ----------------------------------------------------------------------------------------------------------

function checkAndMountCifsDir {
	# Zum Mounten bei den Verzeichnissen das "/" am Ende abschneiden
	local _dirName=$(echo ${1:?"Das Verzeichnis muss übergeben werden"} | sed "s#\/\$##");
	local rc=1;
	
	# Wenn das Verzeichnis schon gemountet ist, passiert nichts, alles gut!
	if [ $(grep "${_dirName}" /etc/mtab 2>/dev/null | wc -l) -eq 0 ]; then
		local _extDirName=${2:?"Externes Verzeichnis muss angegeben werden"};
		local _extUser=${3:?"User für mount muss angegeben werden"};
		local _extPassword=${4:?"Passwort für mount muss angegeben werden"};
		local _extDomain=${5:?"Domain des externen Verzeichnisses muss angegeben werden"};
		local _cedentialsDir="/root/.mount";
		local _cedentialsFile="${_cedentialsDir}/$(echo $_dirName | sed 's#/#_#g').txt";
		
		# Die Credentials in einem File bei root hinterlegen
		mkdir -p "${_cedentialsDir}";
		echo "username=${_extUser}" > ${_cedentialsFile};
		echo "password=${_extPassword}" >> ${_cedentialsFile};
		echo "domain=${_extDomain}" >> ${_cedentialsFile};
		
		# Nun das Verzeichnis mit diesem Credentials-File mounten
		mount -t cifs "${_extDirName}" "${_dirName}" -o "auto,credentials=${_cedentialsFile},dir_mode=0700,file_mode=0700,uid=root,forceuid,gid=root,forcegid" 2>/dev/null 1>/dev/null;
		if [ $(grep "${_dirName}" /etc/mtab 2>/dev/null | wc -l) -eq 0 ]; then
			rc=0;
		fi;
		
		# Das temporäre Credentials-File wieder wegräumen
		rm -f "${_cedentialsFile}" 2>/dev/null;
		rmdir "${_cedentialsDir}" 2>/dev/null;
	fi;

	return ${rc};
}
