#!/bin/sh

# Définir les répertoires nécessaires
OWASPDC_DIRECTORY=$HOME/OWASP-Dependency-Check
DATA_DIRECTORY="$OWASPDC_DIRECTORY/data"
REPORT_DIRECTORY="$OWASPDC_DIRECTORY/reports"
if [ ! -d "$DATA_DIRECTORY" ]; then
    echo "Initially creating persistent directories"
    mkdir -p "$DATA_DIRECTORY"
    chmod -R 777 "$DATA_DIRECTORY"

    mkdir -p "$REPORT_DIRECTORY"
    chmod -R 777 "$REPORT_DIRECTORY"
fi

# Clé API NVD
NVD_API_KEY="1676d6a0-7c25-4f36-91bd-27389b01e451"

# Exécuter le scan avec Docker
docker run --rm \
    --volume "`pwd`":/src \
    --volume "$DATA_DIRECTORY":/usr/share/dependency-check/data \
    --volume "$REPORT_DIRECTORY":/report \
    owasp/dependency-check \
    --scan /src \
    --format "HTML" \
    --project "My OWASP Dependency Check Project" \
    --out /report \
    --nvdApiKey "$NVD_API_KEY" \
    --log /report/dependency-check.log

