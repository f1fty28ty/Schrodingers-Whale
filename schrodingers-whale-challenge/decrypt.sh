#!/usr/bin/env bash
# Two-layer decryption helper for Fragment 3

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <encrypted_hex> <key>"
    echo ""
    echo "Example:"
    echo "  $0 '5c6a7b...' 'key_here'"
    echo ""
    echo "This performs two-layer decryption:"
    echo "  1. XOR decrypt with SHA256(key)"
    echo "  2. Base64 decode the result"
    exit 1
fi

ENCRYPTED="$1"
KEY="$2"

echo "=== Two-Layer Decryption Process ==="
echo "Key: $KEY"
echo ""

# Step 1: Compute SHA256 of key
KEY_HASH=$(echo -n "$KEY" | sha256sum | cut -d' ' -f1)
echo "Step 1 - SHA256 of key: $KEY_HASH"
echo ""

# Step 2: XOR decrypt
echo "Step 2 - XOR decrypting..."
DECRYPTED=""
ENCRYPTED_LEN=${#ENCRYPTED}
KEY_LEN=${#KEY_HASH}

for ((i=0; i<ENCRYPTED_LEN; i+=2)); do
    ENCRYPTED_BYTE="${ENCRYPTED:$i:2}"
    
    KEY_POS=$(( (i/2) % (KEY_LEN/2) ))
    KEY_BYTE="${KEY_HASH:$((KEY_POS*2)):2}"
    
    ENCRYPTED_DEC=$((16#$ENCRYPTED_BYTE))
    KEY_DEC=$((16#$KEY_BYTE))
    XOR_RESULT=$(($ENCRYPTED_DEC ^ $KEY_DEC))
    
    printf -v XOR_HEX "%02x" $XOR_RESULT
    DECRYPTED="${DECRYPTED}${XOR_HEX}"
done

# Convert hex to text (should be base64)
DECRYPTED_B64=$(echo -n "$DECRYPTED" | xxd -r -p)
echo "After XOR: $DECRYPTED_B64"
echo ""