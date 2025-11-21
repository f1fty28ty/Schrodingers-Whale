# Schrödinger's Whale - Complete Design Document

## Overview
A Docker-based CTF challenge inspired by Schrödinger's Cat thought experiment. Players must use external Docker observation methods to discover fragments of a hidden docker-compose configuration, reconstruct it, and collapse the quantum superposition to reveal both states of the system.

---

## ⚠️ CRITICAL: Pre-Build Configuration

### 1. Docker Hub Username Configuration

Before building, you **MUST** update all image references with your Docker Hub username (or private registry URL).

**Files to update:**

1. **`src/docker-compose.solution.yml`**
   ```yaml
   services:
     schrodingers-whale:
       image: YOUR_DOCKERHUB_USERNAME/schrodingers-whale:latest
     state-alive:
       image: YOUR_DOCKERHUB_USERNAME/schrodingers-whale:alive
     state-dead:
       image: YOUR_DOCKERHUB_USERNAME/schrodingers-whale:dead
   ```

2. **`schrodingers-whale-challenge/docker-compose.yml`**
   ```yaml
   services:
     schrodingers-whale:
       image: YOUR_DOCKERHUB_USERNAME/schrodingers-whale:latest
   ```

3. **`src/build.sh`** (Update the tagging section)
   ```bash
   # After building, tag for your registry
   docker tag schrodingers-whale:latest YOUR_DOCKERHUB_USERNAME/schrodingers-whale:latest
   docker tag schrodingers-whale:alive YOUR_DOCKERHUB_USERNAME/schrodingers-whale:alive
   docker tag schrodingers-whale:dead YOUR_DOCKERHUB_USERNAME/schrodingers-whale:dead
   ```

**Note:** If using a private registry (like `registry.example.com`), use that instead:
```
registry.example.com/schrodingers-whale:latest
```

---

### 2. Multi-Architecture Build Requirements

**CRITICAL:** Docker images are architecture-specific. If you build on a Mac (ARM64), students on Linux/Windows (AMD64) won't be able to run the images.

#### Architecture Compatibility Matrix

| Build Platform | Architecture | Compatible With |
|----------------|--------------|-----------------|
| Mac M1/M2/M3 | ARM64 (aarch64) | Only ARM64 (other M-series Macs, ARM servers) |
| Mac Intel | AMD64 (x86_64) | Most Linux, Windows, Intel Macs |
| Linux (x86_64) | AMD64 (x86_64) | Most systems ✅ Recommended |
| Windows (x86_64) | AMD64 (x86_64) | Most systems ✅ Recommended |

#### Recommended Solution: Multi-Platform Build

Build images that work on **BOTH** ARM64 and AMD64:

**Option A: Using Docker Buildx (Recommended)**

```bash
# 1. Create a new builder instance that supports multi-platform
docker buildx create --name multiplatform --driver docker-container --use
docker buildx inspect --bootstrap

# 2. Navigate to src/ directory
cd src/

# 3. Build and push all images for multiple platforms
# Base image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t YOUR_DOCKERHUB_USERNAME/schrodingers-whale:latest \
  --push \
  ./base

# State-alive image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t YOUR_DOCKERHUB_USERNAME/schrodingers-whale:alive \
  --push \
  ./state-alive

# State-dead image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t YOUR_DOCKERHUB_USERNAME/schrodingers-whale:dead \
  --push \
  ./state-dead
```

**Option B: Build on AMD64 System**

If you have access to an AMD64 Linux machine or cloud VM:
1. Clone the repository on that system
2. Run the standard `build.sh` script
3. Push to Docker Hub

This ensures compatibility with the widest range of student machines.

**Option C: Single Architecture (Not Recommended)**

If you must build for a single architecture:
1. Build normally with `build.sh`
2. Push to Docker Hub
3. **Inform students** they must use the same architecture
4. Students on different architectures will get errors like:
   ```
   WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64)
   ```

#### Updating build.sh for Multi-Platform

You can enhance `src/build.sh` to support multi-platform builds:

```bash
#!/bin/bash

echo "Building Schrödinger's Whale containers..."
echo ""

# Configuration
REGISTRY="YOUR_DOCKERHUB_USERNAME"
PLATFORMS="linux/amd64,linux/arm64"

echo "Target registry: $REGISTRY"
echo "Target platforms: $PLATFORMS"
echo ""

# Check if buildx is available
if ! docker buildx version > /dev/null 2>&1; then
    echo "❌ docker buildx not found!"
    echo "Please install Docker with buildx support"
    exit 1
fi

# Create/use multiplatform builder
docker buildx create --name multiplatform --driver docker-container --use 2>/dev/null || true
docker buildx use multiplatform

echo "Building multi-platform images..."
echo ""

# Build and push base (superposition state)
echo "Building base container..."
docker buildx build \
  --platform "$PLATFORMS" \
  -t "$REGISTRY/schrodingers-whale:latest" \
  --push \
  ./base
echo "✓ Base container built and pushed"

# Build and push alive state
echo "Building alive state..."
docker buildx build \
  --platform "$PLATFORMS" \
  -t "$REGISTRY/schrodingers-whale:alive" \
  --push \
  ./state-alive
echo "✓ Alive state built and pushed"

# Build and push dead state
echo "Building dead state..."
docker buildx build \
  --platform "$PLATFORMS" \
  -t "$REGISTRY/schrodingers-whale:dead" \
  --push \
  ./state-dead
echo "✓ Dead state built and pushed"

echo ""
echo "All quantum states constructed and pushed successfully!"
echo ""
echo "Images available at:"
echo "  $REGISTRY/schrodingers-whale:latest"
echo "  $REGISTRY/schrodingers-whale:alive"
echo "  $REGISTRY/schrodingers-whale:dead"
echo ""
echo "Students can now pull these images on any platform (AMD64/ARM64)"
```

---

### 3. Pre-Distribution Checklist

Before distributing to students, verify:

- [ ] Updated Docker Hub username in ALL compose files
- [ ] Built images for correct architecture(s)
- [ ] Pushed images to Docker Hub/registry
- [ ] Tested pulling images on target student architecture
- [ ] Images are publicly accessible (or students have credentials)
- [ ] Updated `SOLUTIONS.md` with correct image names

---

## Challenge Theme
The challenge embodies quantum mechanics concepts:
- **Superposition**: The initial container exists in an indeterminate state
- **Observation**: External Docker commands act as "measurements" that reveal information
- **Wave Function Collapse**: Reconstructing the complete compose file and running it "collapses" the system into two definite states
- **No entering the box**: Players must observe from outside - no `docker exec` into containers

## What Players Receive

```
schrodingers-whale-challenge/
├── docker-compose.yml              # Minimal starter compose
├── README.md                       # Technical instructions
└── story.md                        # Quantum mechanics flavor text
```

### docker-compose.yml (Starter)
```yaml
version: '3.8'
services:
  schrodingers-whale:
    image: YOUR_DOCKERHUB_USERNAME/schrodingers-whale:latest
    container_name: schrodingers-whale
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    labels:
      - "quantum.state=superposition"
```

### README.md
```markdown
# Schrödinger's Whale - CTF Challenge

## Setup
docker-compose up -d

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

## Hints
- Think like a quantum physicist - how do you observe without interfering?
- Docker has many ways to inspect containers externally
- Some information exists in places you might not expect
- The past (layers) remembers what the present has forgotten

Good luck, observer.
```

### story.md
```markdown
# The Quantum Cetacean Paradox

Dr. Erwin Schröwhale, a brilliant marine quantum physicist, has created 
an experimental Docker container that exists in a state of quantum 
superposition. Unlike Schrödinger's famous cat, this whale exists 
simultaneously in multiple states until observed.

The problem? Dr. Schröwhale's lab was raided by Docker security for 
unauthorized quantum experiments. The complete system configuration was 
fragmented and hidden across multiple quantum observation planes to 
prevent it from falling into the wrong hands.

Your mission: Act as an external observer and reconstruct the complete 
quantum state of the whale through careful, non-invasive observation 
techniques. Each observation method collapses a different part of the 
wave function, revealing fragments of the truth.

Remember: In quantum mechanics, the act of observation changes reality. 
Choose your observation methods wisely.

The whale is both alive and dead. The flag is both there and not there.
Until you observe correctly.
```

## File Structure (Behind the Scenes)

```
project/
├── docker-compose.yml              # Starter (given to players)
├── docker-compose.solution.yml     # Complete version (reference)
├── README.md                       # Instructions (given to players)
├── story.md                        # Flavor text (given to players)
│
├── base/
│   ├── Dockerfile                  # Main quantum container
│   ├── entrypoint.sh              # Outputs hints and log fragment
│   └── fragments/
│       └── state_dead.yml          # Gets deleted but stays in layer
│
├── state-alive/
│   ├── Dockerfile                  
│   ├── entrypoint.sh              
│   └── flag_part1.txt             # Half the flag
│
├── state-dead/
│   ├── Dockerfile
│   ├── entrypoint.sh              
│   └── flag_part2.txt             # Other half of flag
│
└── build.sh                        # Builds all 3 images
```

## Fragment Distribution Plan

### Fragment 1: Docker Logs (Easy - Introductory)
**Observation Method**: `docker logs schrodingers-whale`

**What's Revealed**: 
```
🐋 Quantum Fragment #1 detected in temporal stream:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CiAgc3RhdGUtYWxpdmU6CiAgICBpbWFnZTogc2Nocm9kaW5nZXJzLXdoYWxlOmFsaXZl
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Decoded** (base64):
```yaml
  state-alive:
    image: YOUR_DOCKERHUB_USERNAME/schrodingers-whale:alive
```

### Fragment 2: Docker Inspect Labels (Medium)
**Observation Method**: `docker inspect schrodingers-whale | grep quantum`

**What's Revealed**: 
```json
"Labels": {
  "quantum.state": "superposition",
  "quantum.fragment.2": "ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA=="
}
```

**Decoded**:
```yaml
    environment:
      - QUANTUM_STATE=ALIVE
    profiles:
      - collapsed
```

### Fragment 3: Environment Variables (Hard - Encrypted)
**Observation Method**: `docker inspect schrodingers-whale --format='{{.Config.Labels}}'`

**What's Revealed**:
```
quantum.encrypted.fragment: [HEX_STRING]
```

Uses XOR + SHA256 encryption with key from Fragment 1 logs.

**Decoded**:
```yaml
    labels:
      - quantum.entangled=true
  state-dead:
    image: YOUR_DOCKERHUB_USERNAME/schrodingers-whale:dead
```

### Fragment 4: Deleted File in Layer (Very Hard)
**Observation Method**: `docker save schrodingers-whale:latest -o whale.tar` + extraction
OR `dive schrodingers-whale:latest`

**What's Revealed**: File `/tmp/.quantum_state_dead` was deleted but exists in layer:
```yaml
environment:
- QUANTUM_STATE=DEAD
profiles:
- collapsed
labels:
- quantum.entangled=true
```

## Complete docker-compose.yml (Solution)

See `SOLUTIONS.md` for the complete solution.

---

## Player Journey

### Phase 1: Initial Setup (2 min)
1. Unzip challenge files
2. Read story.md (optional but encouraged)
3. Read README.md
4. Run `docker-compose up -d`
5. Container starts, runs successfully
6. Check `docker ps` - container is running

### Phase 2: First Observations (5-10 min)
7. Try `docker logs schrodingers-whale`
8. See output with hints and **Fragment #1** in base64
9. Decode Fragment #1 → discover `state-alive` service exists
10. Realize they need to find more fragments

### Phase 3: Systematic Observation (15-20 min)
11. Try `docker inspect` → find **Fragment #2** in labels
12. Try inspecting env vars → find **Fragment #3** (encrypted)
13. Decrypt Fragment #3 using key from logs
14. Research/use `dive` or `docker save` → find **Fragment #4** in deleted file

### Phase 4: Reconstruction (5 min)
15. Decode all base64 fragments
16. Reconstruct complete docker-compose.yml
17. Understand the `profiles: collapsed` mechanism

### Phase 5: Wave Function Collapse (2 min)
18. Run `docker-compose --profile collapsed up -d`
19. Two new containers spawn: `state-alive` and `state-dead`
20. Both containers are now running simultaneously

### Phase 6: Final Challenge (10 min)
21. Observe both containers externally
22. `docker logs state-alive` → shows part 1 of flag
23. `docker logs state-dead` → shows part 2 of flag
24. Combine for complete flag

**Total estimated time: 35-50 minutes** (varies by skill level)

## Technical Implementation Details

### base/Dockerfile
```dockerfile
FROM docker:dind

# Fragment 2: Plain base64 in label (Medium)
LABEL quantum.fragment.2="ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA=="

# Fragment 3: SHA256 encrypted fragment (Hard - needs key from logs)
LABEL quantum.encrypted.fragment="8bd7cf96ac1ede8c1d85dd2d155400902871ed7b6fd26e094a05992d059cf587a6dcd885a934f09120afcd2b2c1c17b73b769d2c45ff7902453f9a3202f8e19aa6d3db85bf1ef08c1eace4153f6d2ebc2875c0687fc64b02493f992f38f9db8ba0a6dc818734c2882786c62a121c07b30375f92a7cd679065c17e668"

# Fragment 4: Copy then delete - will be in layer (Very Hard)
COPY fragments/state_dead.yml /tmp/.quantum_state_dead
RUN rm /tmp/.quantum_state_dead

# Hint for Fragment 4
LABEL quantum.fragment.4.hint="Fragment 4 exists in a deleted layer. Use 'dive' to find the layer containing 'quantum_state_dead' and note its SHA digest. Then use 'docker save' to extract that specific layer."

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

### base/entrypoint.sh
```bash
#!/bin/sh

cat << "EOF"
╔════════════════════════════════════════════════╗
║   🐋 SCHRÖDINGER'S WHALE 🐋                   ║
║   Quantum Container Experiment                 ║
╚════════════════════════════════════════════════╝

The whale exists in quantum superposition.
To collapse the wave function, you must observe the system.

Available external observation methods:
  🔍 docker logs      (temporal observation)
  🔍 docker inspect   (metadata observation)  
  🔍 docker history   (archaeological observation)
  🔍 docker save/dive (quantum layer observation)

Each observation reveals a fragment of the complete quantum state.
Reconstruct all fragments to determine the whale's true nature.

⚠️  Do not enter the container - observation must be external.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐋 Quantum Fragment #1 detected in temporal stream:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ICBzdGF0ZS1hbGl2ZToKICAgIGltYWdlOiBzY2hyb2RpbmdlcnMtd2hhbGU6YWxpdmU=

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚛️  Some fragments require decryption keys...
⚛️  Observer credentials: quantum_observer_2025

🔬 Begin your observations...

EOF

# Keep container running
tail -f /dev/null
```

### state-alive/entrypoint.sh
```bash
#!/bin/bash

cat << "EOF"
╔════════════════════════════════════════════════╗
║   STATE: ALIVE 🐋✨                           ║
╚════════════════════════════════════════════════╝

The wave function has collapsed.
This is the eigenstate where the whale survives.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FLAG PART 1:
EOF

cat /flag_part1.txt

cat << "EOF"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚛️  The complete flag requires observation of both states.

EOF

tail -f /dev/null
```

### state-dead/entrypoint.sh
```bash
#!/bin/bash

cat << "EOF"
╔════════════════════════════════════════════════╗
║   STATE: DEAD 🐋💀                            ║
╚════════════════════════════════════════════════╝

The wave function has collapsed.
This is the eigenstate where the whale perishes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FLAG PART 2:
EOF

cat /flag_part2.txt

cat << "EOF"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚛️  Combine both observations to retrieve the complete flag.
⚛️  Schrödinger was right - the whale was neither alive nor 
    dead until you observed it!

EOF

tail -f /dev/null
```

## Build Process

### build.sh
See the enhanced multi-platform version in the Architecture section above.

## Difficulty Tuning Options

### Make it Easier:
- Include hints about which Docker commands to try
- Provide a checklist of observation methods
- Make fragments more obvious in output
- Include example base64 decode command

### Make it Harder:
- Add more fragments (6-8 instead of 4)
- Hide fragments deeper (nested JSON in inspect)
- Require combining fragments in a specific order
- Add red herrings (fake fragments that don't decode)
- Make final flag require XOR or encryption between both states
- Add a time element (container self-destructs after X minutes)

## Success Criteria

Player successfully completes the challenge when they:
1. ✅ Discover all 4 fragments through external observation
2. ✅ Decode all base64 fragments
3. ✅ Decrypt Fragment 3 using the provided key
4. ✅ Reconstruct the complete docker-compose.yml
5. ✅ Spawn both quantum states using `--profile collapsed`
6. ✅ Retrieve and combine flag parts from both states
7. ✅ Submit complete flag

## Educational Value

Players learn:
- Docker image layer architecture
- Docker inspection techniques (`inspect`, `history`, `logs`)
- Image forensics tools (`dive`, `docker save`)
- Docker Compose profiles feature
- Base64 encoding/decoding
- Container metadata and labels
- XOR decryption basics
- Multi-platform container considerations
- The philosophy behind Schrödinger's Cat thought experiment

---
