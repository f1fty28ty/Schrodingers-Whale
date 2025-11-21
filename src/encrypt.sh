#!/usr/bin/env bash
# SHA256 XOR encryption for Docker label (with base64 layer)

# Key/salt from logs
KEY="quantum_observer_2025"

# Fragment to encrypt (the actual YAML we want to hide)
FRAGMENT="    labels:
      - quantum.entangled=true"

echo "=== Two-Layer Encryption Process ==="
echo "Key: $KEY"
echo "Fragment to encrypt:"
echo "$FRAGMENT"
echo ""

# Step 1: Base64 encode the fragment
FRAGMENT_B64=$(echo -n "$FRAGMENT" | base64)
echo "Step 1 - Base64 encoded: $FRAGMENT_B64"
echo ""

# Step 2: Compute SHA256 hash of the key
KEY_HASH=$(echo -n "$KEY" | sha256sum | cut -d' ' -f1)
echo "Step 2 - SHA256 of key: $KEY_HASH"
echo ""

# Step 3: Convert base64 string to hex
FRAGMENT_HEX=$(echo -n "$FRAGMENT_B64" | xxd -p | tr -d '\n')
echo "Step 3 - Base64 as hex: $FRAGMENT_HEX"
echo ""

# Step 4: XOR the base64 string with the key hash (repeating key as needed)
FRAGMENT_LEN=${#FRAGMENT_HEX}
KEY_LEN=${#KEY_HASH}
ENCRYPTED=""

for ((i=0; i<FRAGMENT_LEN; i+=2)); do
    # Get two hex chars from fragment (one byte)
    FRAGMENT_BYTE="${FRAGMENT_HEX:$i:2}"
    
    # Get corresponding byte from key hash (wrap around if needed)
    KEY_POS=$(( (i/2) % (KEY_LEN/2) ))
    KEY_BYTE="${KEY_HASH:$((KEY_POS*2)):2}"
    
    # XOR the bytes
    FRAGMENT_DEC=$((16#$FRAGMENT_BYTE))
    KEY_DEC=$((16#$KEY_BYTE))
    XOR_RESULT=$(($FRAGMENT_DEC ^ $KEY_DEC))
    
    # Convert back to hex
    printf -v XOR_HEX "%02x" $XOR_RESULT
    ENCRYPTED="${ENCRYPTED}${XOR_HEX}"
done

echo "Step 4 - XOR encrypted (hex): $ENCRYPTED"
echo ""
echo "=== Put this in Dockerfile ==="
echo "LABEL quantum.encrypted.fragment=\"$ENCRYPTED\""
echo ""

# Test decryption
echo "=== Testing Decryption Process ==="

# Decrypt: XOR with key
DECRYPTED=""
ENCRYPTED_LEN=${#ENCRYPTED}

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

# Convert hex back to base64 string
DECRYPTED_B64=$(echo -n "$DECRYPTED" | xxd -r -p)
echo "After XOR decrypt: $DECRYPTED_B64"
echo ""

# Decode base64 to get final fragment
DECRYPTED_TEXT=$(echo -n "$DECRYPTED_B64" | base64 -d)
echo "After base64 decode:"
echo "$DECRYPTED_TEXT"
echo ""

if [ "$DECRYPTED_TEXT" = "$FRAGMENT" ]; then
    echo "✅ Two-layer encryption/decryption successful!"
else
    echo "❌ Decryption failed - mismatch"
fi