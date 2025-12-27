#!/usr/bin/env bash
echo "Processing large dataset..."
for i in {1..3}; do
    echo "Working on batch $i..."
    sleep 1
done
echo "Cleanup complete."
exit 0