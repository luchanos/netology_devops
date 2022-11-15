#! /bin/bash
for n in {1..300000}; do
  printf $n
# shellcheck disable=SC2086
#  touch $n.bin
#  [[ -s /tmp ]]: [[printf "sample text" > "$n.bin"]]
done

#https://stackoverflow.com/questions/3427872/whats-the-difference-between-and-in-bash