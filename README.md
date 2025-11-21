# Schrödinger's Whale - CTF Challenge

## Prerequisites
- Docker
- Docker Compose

## Setup
Start the quantum experiment:
```bash
docker-compose up -d

#later this

docker-compose --profile collapsed up -d
```

Check that the container is running:
```bash
docker ps
```

## Objective
The whale exists in quantum superposition. Your goal is to:
1. Observe the system using external methods only
2. Collect quantum fragments from different observation techniques
3. Reconstruct the complete quantum state
4. Collapse the wave function to reveal both possible states

## Rules
- Do NOT enter the container (`docker exec` defeats the purpose)
- All observations must be external
- Multiple observation methods reveal different information
- Combine all fragments to reconstruct reality

## Available Observation Methods

Docker provides several ways to externally observe containers without entering them:

### Basic Observations
- `docker logs <container>` - View container output (temporal observation)
- `docker inspect <container>` - View container metadata and configuration
- `docker ps` - List running containers

### Advanced Observations
- `docker history <image>` - View image layer history (archaeological observation)
- `docker save <image> -o file.tar` - Export image to tarball for analysis
- `dive <image>` - Explore image layers interactively (recommended for finding hidden files)

### Installing dive (Image Layer Explorer)
**macOS:**
```bash
brew install dive
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install dive
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install dive
```

**Other systems:**
See [dive releases](https://github.com/wagoodman/dive/releases) for pre-built binaries

### Useful Inspection Filters
- `docker inspect <container> | grep quantum` - Search for specific metadata
- `docker inspect <container> --format='{{.Config.Env}}'` - View environment variables
- `docker inspect <container> --format='{{.Config.Labels}}'` - View labels

## Hints
- Start with `docker logs` to see what the container is telling you
- Look for base64 encoded strings - they often contain hidden information
- Image layers remember what the present has forgotten
- Some fragments are in metadata (labels, environment variables)
- Each observation method reveals different aspects of the quantum state
- You'll need to combine information from multiple sources

## Decoding Base64
If you find base64 encoded strings, decode them with:
```bash
echo "BASE64_STRING_HERE" | base64 -d
```

Good luck, observer.
