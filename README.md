# Schrödinger's Whale - Instructor Setup Guide

## Overview
A Docker-based CTF challenge that teaches Docker forensics, image inspection, and container observation techniques through a quantum mechanics-themed puzzle. Players must use external Docker observation methods to discover fragments of a hidden docker-compose configuration and reconstruct it to reveal the flag.

**Difficulty:** Medium to Hard  
**Estimated Time:** 35-50 minutes  
**Skills Taught:** Docker inspection, image layer analysis, base64 decoding, container forensics

---

## For Instructors: Quick Setup

### Prerequisites
- Docker and Docker Compose installed
- `dive` tool (optional but recommended for students)
- Access to Docker Hub or a private registry

### Step 1: Build the Challenge Images

Navigate to the `src/` directory and run the build script:

```bash
cd src/
chmod +x build.sh
./build.sh
```

This creates three Docker images:
- `schrodingers-whale:latest` (main challenge container)
- `schrodingers-whale:alive` (solution container 1)
- `schrodingers-whale:dead` (solution container 2)

### Step 2: Push to Registry (Recommended)

For a distributed CTF, push the images to Docker Hub or your private registry:

```bash
# Tag for your registry
docker tag schrodingers-whale:latest your-dockerhub-username/schrodingers-whale:latest
docker tag schrodingers-whale:alive your-dockerhub-username/schrodingers-whale:alive
docker tag schrodingers-whale:dead your-dockerhub-username/schrodingers-whale:dead

# Push
docker push your-dockerhub-username/schrodingers-whale:latest
docker push your-dockerhub-username/schrodingers-whale:alive
docker push your-dockerhub-username/schrodingers-whale:dead
```

**Note:** Update the image names in `schrodingers-whale-challenge/docker-compose.yml` and `src/docker-compose.solution.yml` to match your registry.

### Step 3: Prepare Student Distribution Package

Create a clean challenge directory for students:

```bash
# From project root
mkdir -p student-distribution
cp -r schrodingers-whale-challenge/* student-distribution/
cd student-distribution

# Optional: Create a zip file
zip -r schrodingers-whale-challenge.zip .
```

Distribute the `student-distribution` folder or ZIP file to students.

### Step 4: Student Instructions

Students should:
1. Extract the challenge files to an isolated directory
2. Navigate to that directory
3. Start the challenge:
   ```bash
   docker-compose up -d
   ```
4. Begin their observations

---

## Challenge Structure

### What Students Receive
```
schrodingers-whale-challenge/
├── docker-compose.yml       # Starter compose file (incomplete)
├── README.md               # Challenge instructions
├── story.md                # Flavor text
└── decrypt.sh              # Helper for Fragment 3 (encrypted)
```

### What They Must Find
Students must discover **5 fragments** scattered across different Docker observation planes:

| Fragment | Method | Difficulty | Content |
|----------|--------|------------|---------|
| 1 | `docker logs` | Easy | `state-alive` service definition |
| 2 | `docker inspect` (labels) | Medium | Environment vars for alive state |
| 3 | `docker inspect` (encrypted label) | Hard | Labels and `state-dead` definition |
| 4 | Image layers (`dive`/`docker save`) | Very Hard | `state-dead` environment vars |

### Solution Reference

Complete solutions, including the final docker-compose.yml and flag, are documented separately in `SOLUTIONS.md`. This file should **NOT** be shared with students until after completion.

---

## Helper Commands for Students

### Installation Commands

**Install dive (image layer explorer):**
```bash
# macOS
brew install dive

# Fedora/RHEL
sudo dnf install dive

# Debian/Ubuntu
sudo apt install dive

# Or download from: https://github.com/wagoodman/dive/releases
```

### Basic Observation Commands

```bash
# Check running containers
docker ps

# View container logs (Fragment 1)
docker logs schrodingers-whale

# Inspect container metadata (Fragments 2 & 3)
docker inspect schrodingers-whale

# Search for quantum-related labels
docker inspect schrodingers-whale | grep quantum

# View environment variables
docker inspect schrodingers-whale --format='{{.Config.Env}}'

# View all labels
docker inspect schrodingers-whale --format='{{.Config.Labels}}'
```

### Advanced Observation Commands

```bash
# Explore image layers interactively (Fragment 4)
dive schrodingers-whale:latest

# Export image for forensic analysis
docker save schrodingers-whale:latest -o whale.tar
tar -xf whale.tar

# Search for deleted files in layers
for blob in blobs/sha256/*; do 
    tar -tf "$blob" 2>/dev/null | grep quantum_state_dead && echo "Found in: $blob"
done

# Extract specific layer
tar -xf blobs/sha256/<hash-from-above> tmp/.quantum_state_dead

# Read the deleted file
cat tmp/.quantum_state_dead
```

### Decoding Commands

```bash
# Decode base64 strings
echo "BASE64_STRING" | base64 -d

# Decrypt Fragment 3 (students get decryption key from logs)
./decrypt.sh '<encrypted_hex_from_label>' 'quantum_observer_2025'
```

### Solution Commands

```bash
# Once compose file is reconstructed, spawn both states
docker-compose --profile collapsed up -d

# View both states
docker logs state-alive   
docker logs state-dead    

# Look within both states for the full flag
```

---

## Monitoring Student Progress

### Check If Students Have Started
```bash
docker ps --filter "name=schrodingers-whale"
```

### Check If Students Have Found Fragments
Students should be running these commands:
- `docker logs` - Fragment 1
- `docker inspect` - Fragments 2 & 3
- `dive` or `docker save` - Fragment 4

### Check If Students Have Solved It
```bash
# Look for the collapsed state containers
docker ps --filter "name=state-alive"
docker ps --filter "name=state-dead"
```

If both containers exist, students have reconstructed the compose file successfully. See `SOLUTIONS.md` for the complete solution details.

---

## Troubleshooting

### Students Can't Pull Images
Ensure images are public on Docker Hub or students have registry credentials:
```bash
docker login
# Then pull
docker pull your-registry/schrodingers-whale:latest
```

### Students Accidentally Enter Container
If students use `docker exec`:
```bash
docker exec -it schrodingers-whale sh
```

Remind them this defeats the purpose. The challenge is about **external observation only**.

### dive Not Working
Alternative to `dive`:
```bash
# Use docker save method
docker save schrodingers-whale:latest -o whale.tar
tar -xf whale.tar
# Then manually search layer blobs
```

### Fragment 3 Decryption Issues
Students need the key from the logs output:
```
⚛️  Observer credentials: quantum_observer_2025
```

Remind them to use the `decrypt.sh` script provided.

---

## Customization Options

### Make It Easier
1. **Remove Fragment 3 encryption** - Make it plain base64 in Dockerfile
2. **Add more hints** - Modify `entrypoint.sh` to be more explicit
3. **Provide tool tutorials** - Include `dive` usage guide
4. **Reduce fragments** - Combine Fragments 2 & 3

### Make It Harder
1. **Add more fragments** - Split across 6-8 observations
2. **Deeper nesting** - Hide fragments in nested JSON paths
3. **Multi-layer encryption** - Add AES encryption to Fragment 3
4. **Time limit** - Container self-destructs after X minutes
5. **Red herrings** - Add fake fragments that don't decode
6. **Flag assembly puzzle** - Require XORing both flag parts

### Change the Flag
Edit these files:
- `src/state-alive/flag_part1.txt`
- `src/state-dead/flag_part2.txt`

Then rebuild images with `build.sh`. Update `SOLUTIONS.md` accordingly.

---

## Educational Value

### Skills Students Learn
- Docker image layer architecture
- Container inspection techniques (`inspect`, `history`, `logs`)
- Image forensics tools (`dive`, `docker save`)
- Understanding Docker layer caching and deletion
- Base64 encoding/decoding
- Docker Compose profiles feature
- XOR decryption basics (Fragment 3)
- Forensic analysis mindset

### Learning Outcomes
By completing this challenge, students will:
1. Understand that deleted files in Docker layers aren't truly deleted
2. Learn multiple methods to inspect containers externally
3. Practice Docker security auditing techniques
4. Gain experience with common Docker forensics tools
5. Understand the immutability of Docker layers

---

## Walkthrough Documents

Detailed walkthroughs and solutions are available in:
- `SOLUTIONS.md` - Complete solutions including flag and compose file (**DO NOT share with students**)
- `Fragment 5 Walkthrough.md` - Detailed guide for the hardest fragment
- `Project Doc.md` - Full design document

These should NOT be shared with students until after completion.

---

## Time Estimates

**By Experience Level:**
- Beginners (first CTF): 60-90 minutes
- Intermediate (familiar with Docker): 35-50 minutes
- Advanced (Docker forensics exp): 20-30 minutes

**By Fragment:**
- Fragment 1 (logs): 2-5 minutes
- Fragment 2 (inspect labels): 5-10 minutes
- Fragment 3 (encrypted): 10-15 minutes
- Fragment 4 (deleted layer): 15-30 minutes
- Reconstruction & solution: 5-10 minutes

---

## Support & Feedback

For issues or improvements, contact [your contact info] or open an issue on [repository link].

## License

BSD 3-Clause License

---

**Good luck running your CTF! 🐋⚛️**