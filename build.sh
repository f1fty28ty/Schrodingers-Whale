#!/bin/bash

echo "Building Schrödinger's Whale containers..."

# Build base (superposition state)
docker build -t schrodingers-whale:latest ./base
echo "✓ Base container built"

# Build alive state
docker build -t schrodingers-whale:alive ./state-alive
echo "✓ Alive state built"

# Build dead state
docker build -t schrodingers-whale:dead ./state-dead
echo "✓ Dead state built"

echo ""
echo "All quantum states constructed successfully!"
echo ""
echo "To test:"
echo "  docker-compose up -d"
echo "  docker-compose --profile collapsed up -d"