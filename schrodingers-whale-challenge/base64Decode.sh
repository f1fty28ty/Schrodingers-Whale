#!/usr/bin/env bash
# Decode base64 to get final fragment

if [ -z "$1" ]; then
    echo "Usage: $0 <base64_string>"
    echo ""
    echo "Example:"
    echo "  $0 'ICBzdGF0ZS1hbGl2ZToKICAgIGltYWdlOiBzY2hyb2RpbmdlcnMtd2hhbGU6YWxpdmU=' | base64 -d"
    exit 1
fi


echo "$1" | base64 -d