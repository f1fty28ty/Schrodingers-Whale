#!/bin/bash

DOCKER_USERNAME="f1fty28ty"

echo "Pushing Schrödinger's Whale containers to Docker Hub..."
echo "Make sure you're logged in: docker login"
echo ""

docker push $DOCKER_USERNAME/schrodingers-whale:latest
echo "✓ Base container pushed"

docker push $DOCKER_USERNAME/schrodingers-whale:alive
echo "✓ Alive state pushed"

docker push $DOCKER_USERNAME/schrodingers-whale:dead
echo "✓ Dead state pushed"

echo ""
echo "All images pushed successfully!"
echo ""
echo "Players can now pull with:"
echo "  docker-compose up -d"