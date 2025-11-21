#!/bin/bash


echo "Building Schrödinger's Whale containers..."

# Build base (superposition state)
docker build -t schrodingers-whale:latest ./base
docker tag schrodingers-whale:latest schrodingers-whale:latest
echo "✓ Base container built"

# Build alive state
docker build -t schrodingers-whale:alive ./state-alive
docker tag schrodingers-whale:alive schrodingers-whale:alive
echo "✓ Alive state built"

# Build dead state
docker build -t schrodingers-whale:dead ./state-dead
docker tag schrodingers-whale:dead schrodingers-whale:dead
echo "✓ Dead state built"

echo ""
echo "All quantum states constructed successfully!"
echo ""
echo "To push to Docker Hub, run:"
echo "  docker push schrodingers-whale:latest"
echo "  docker push schrodingers-whale:alive"
echo "  docker push schrodingers-whale:dead"
echo ""
echo "To test locally:"
echo "  docker-compose up -d"
echo "  docker-compose --profile collapsed up -d"