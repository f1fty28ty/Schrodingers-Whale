# Schrödinger's Whale - Complete Design Document

## Overview
A Docker-based CTF challenge inspired by Schrödinger's Cat thought experiment. Players must use external Docker observation methods to discover fragments of a hidden docker-compose configuration, reconstruct it, and collapse the quantum superposition to reveal both states of the system.

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
    image: yourname/schrodingers-whale:latest
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
    image: schrodingers-whale:alive
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

### Fragment 3: Environment Variables (Medium)
**Observation Method**: `docker inspect schrodingers-whale --format='{{.Config.Env}}'`

**What's Revealed**:
```
QUANTUM_FRAGMENT_3=ICAgIGxhYmVsczoKICAgICAgLSBxdWFudHVtLmVudGFuZ2xlZD10cnVl
```

**Decoded**:
```yaml
    labels:
      - quantum.entangled=true
```

### Fragment 4: Docker History (Hard)
**Observation Method**: `docker history schrodingers-whale:latest`

**What's Revealed**: In layer metadata/comments:
```
LABEL quantum.fragment.4=ICBzdGF0ZS1kZWFkOgogICAgaW1hZ2U6IHNjaHJvZGluZ2Vycy13aGFsZTpkZWFk
```

**Decoded**:
```yaml
  state-dead:
    image: schrodingers-whale:dead
```

### Fragment 5: Deleted File in Layer (Hard)
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

```yaml
version: '3.8'
services:
  schrodingers-whale:
    image: schrodingers-whale:latest
    container_name: schrodingers-whale
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    labels:
      - "quantum.state=superposition"
      
  state-alive:
    image: schrodingers-whale:alive
    environment:
      - QUANTUM_STATE=ALIVE
    profiles:
      - collapsed
    labels:
      - quantum.entangled=true
      
  state-dead:
    image: schrodingers-whale:dead
    environment:
      - QUANTUM_STATE=DEAD
    profiles:
      - collapsed
    labels:
      - quantum.entangled=true
```

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
12. Try inspecting env vars → find **Fragment #3**
13. Try `docker history` → find **Fragment #4** reference
14. Research/use `dive` or `docker save` → find **Fragment #5** in deleted file

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
24. Combine: `FLAG{the_whale_is_both_alive_and_dead_until_observed}`

**Total estimated time: 35-50 minutes** (varies by skill level)

## Technical Implementation Details

### base/Dockerfile
```dockerfile
FROM docker:dind

# Fragment 5: Copy then delete (stays in layer)
COPY fragments/state_dead.yml /tmp/.quantum_state_dead
RUN rm /tmp/.quantum_state_dead

# Fragment 2: In labels
LABEL quantum.fragment.2="ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA=="

# Fragment 4: In history
LABEL quantum.fragment.4="ICBzdGF0ZS1kZWFkOgogICAgaW1hZ2U6IHNjaHJvZGluZ2Vycy13aGFsZTpkZWFk"

# Fragment 3: In environment
ENV QUANTUM_FRAGMENT_3="ICAgIGxhYmVsczoKICAgICAgLSBxdWFudHVtLmVudGFuZ2xlZD10cnVl"

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

CiAgc3RhdGUtYWxpdmU6CiAgICBpbWFnZTogc2Nocm9kaW5nZXJzLXdoYWxlOmFsaXZl

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 Begin your observations...

EOF

# Keep container running
tail -f /dev/null
```

### state-alive/entrypoint.sh
```bash
#!/bin/sh

cat << "EOF"
╔════════════════════════════════════════════════╗
║   STATE: ALIVE 🐋✨                           ║
╚════════════════════════════════════════════════╝

The wave function has collapsed.
This is the eigenstate where the whale survives.

FLAG PART 1: FLAG{the_whale_is_both_alive_and_dead_

EOF

tail -f /dev/null
```

### state-dead/entrypoint.sh
```bash
#!/bin/sh

cat << "EOF"
╔════════════════════════════════════════════════╗
║   STATE: DEAD 🐋💀                            ║
╚════════════════════════════════════════════════╝

The wave function has collapsed.
This is the eigenstate where the whale perishes.

FLAG PART 2: until_observed}

Combine both observations to retrieve the complete flag.

EOF

tail -f /dev/null
```

## Build Process

### build.sh
```bash
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
```

## Difficulty Tuning Options

### Make it Easier:
- Include hints about which Docker commands to try
- Provide a checklist of observation methods
- Make fragments more obvious in output
- Include example base64 decode command

### Make it Harder:
- Add more fragments (6-8 instead of 5)
- Hide fragments deeper (nested JSON in inspect)
- Require combining fragments in a specific order
- Add red herrings (fake fragments that don't decode)
- Make final flag require XOR or encryption between both states
- Add a time element (container self-destructs after X minutes)

## Success Criteria

Player successfully completes the challenge when they:
1. ✅ Discover all 5 fragments through external observation
2. ✅ Decode all base64 fragments
3. ✅ Reconstruct the complete docker-compose.yml
4. ✅ Spawn both quantum states using `--profile collapsed`
5. ✅ Retrieve and combine flag parts from both states
6. ✅ Submit complete flag: `FLAG{the_whale_is_both_alive_and_dead_until_observed}`

## Educational Value

Players learn:
- Docker image layer architecture
- Docker inspection techniques (`inspect`, `history`, `logs`)
- Image forensics tools (`dive`, `docker save`)
- Docker Compose profiles feature
- Base64 encoding/decoding
- Container metadata and labels
- The philosophy behind Schrödinger's Cat thought experiment

---

**End of Design Document**