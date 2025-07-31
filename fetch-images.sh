#!/bin/bash
ORG="${ORG:-bitnamisecure}"
PAGE_SIZE=100
repos=()
url="https://hub.docker.com/v2/repositories/${ORG}/?page_size=${PAGE_SIZE}"

while [ -n "$url" ]; do
    response=$(curl -s "$url")
    repos+=($(echo "$response" | jq -r '.results[].name'))
    url=$(echo "$response" | jq -r '.next')
    if [ "$url" == "null" ]; then
        url=""
    fi
done

if [[ "$1" == "--list" ]]; then
    printf '%s\n' "${repos[@]}"
else
    printf '%s,' "${repos[@]}" | sed 's/,$//'
fi
