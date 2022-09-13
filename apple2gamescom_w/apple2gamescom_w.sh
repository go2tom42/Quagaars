#!/bin/bash

FILE=/wikidump/apple2gamescom_w-20220910-wikidump.7z
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    EXIT
fi

Echo "end of apple2gamescom_w.sh"
