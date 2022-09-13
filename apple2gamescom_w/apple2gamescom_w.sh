#!/bin/bash

FILE=/wikidump/apple2gamescom_w-20220910-wikidump.7z
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit 1
fi

echo "end of apple2gamescom_w.sh"
