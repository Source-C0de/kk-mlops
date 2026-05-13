

#!/bin/bash

BASH_DIR="$HOME"

# Get latest Day number
LAST_DAY=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Day_*" \
| sed 's/.*Day_//' \
| sort -n \
| tail -1)


if [-z "$LAST_DAY" ]; then
    NEXT_DAY=1
else
    NEXT_DAY=$((LAST_DAY+1))
fi

NEW_FOLDER="$BASE_DIR/Day_$NEXT_DAY"
mkdir -p "$NEW_FOLDER"


touch "$NEW_FOLDER/task.md"
touch "$NEW_FOLDER/command.txt"

echo "# Tasks for Day $NEXT_DAY" > "$NEW_FOLDER/task.md"

echo "# Commands for Day $NEXT_DAY" > "$NEW_FOLDER/command.txt"

echo "Created: $NEW_FOLDER"

