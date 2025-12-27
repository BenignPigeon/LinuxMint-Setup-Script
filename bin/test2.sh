#!/usr/bin/env bash
echo "Attempting to reach backup server..."
sleep 1
echo "Error: Connection refused (Port 8080)" >&2

# pause
echo
echo "Press any key to continue..."
read -n 1 -s -r
# --------------------

exit 1