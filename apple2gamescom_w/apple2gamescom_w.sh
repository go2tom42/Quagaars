#!/bin/bash

base=${1}
date=${2}

FILE=/wikidump/$base-$date-wikidump.7z
[ -f "$FILE" ] || { echo "File $FILE not found" && exit 0; }

echo "end of apple2gamescom_w.sh"
