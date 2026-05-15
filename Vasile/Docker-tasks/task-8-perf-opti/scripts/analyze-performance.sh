#!/bin/bash

mkdir -p results

touch results/image-sizes.txt

docker images > results/image-sizes.txt

touch results/runtime-stats.txt

docker stats --no-stream > results/runtime-stats.txt

echo "Performance analysis completed."