#!/usr/bin/env bash
# Bash equivalent of the Python SHA256 XOR encryption script

# Key from logs
key="quantum_observer_2025"

# Fragment to encrypt (base64 of the YAML)
fragment="ICBzdGF0ZS1kZWFkOgogICAgaW1hZ2U6IGYxZnR5Mjh0eS9zY2hyb2RpbmdlcnMtd2hhbGU6ZGVhZA=="

# Compute SHA256 of key (raw binary)
key_hash=$(echo -n "$key" | openssl dgst -sha256 -binary)

# Convert fragment to bytes
fragment_bytes=$(echo -n "$fragment" | xxd -p -c 256)

# Function to XOR two byte streams (hex strings)
xor_hex() {
  local data_hex="$1"
  local key_hex="$2"
  local result=""
  local data_len=$(( ${#data_hex} / 2 ))
  local key_len=$(( ${#key_hex} / 2 ))

  for ((i=0; i<data_len; i++)); do
    local data_byte=$((16#${data_hex:i*2:2}))
    local key_byte=$((16#${key_hex:$(( (i % key_len)*2 )):2}))
    printf -v result "%s%02x" "$result" $((data_byte ^ key_byte))
  done
  echo "$result"
}

# Convert key_hash to hex
key_hash_hex=$(echo -n "$key_hash" | xxd -p | tr -d '\n')

# XOR encrypt
encrypted_hex=$(xor_hex "$fragment_bytes" "$key_hash_hex")

echo "Encrypted hex:"
echo "$encrypted_hex"
