# Schrödinger's Whale - Complete Solutions Guide

⚠️ **INSTRUCTOR ONLY - DO NOT SHARE WITH STUDENTS BEFORE COMPLETION**

This document contains all solutions, answers, and the complete walkthrough for the Schrödinger's Whale CTF challenge.

---

## Table of Contents
1. [Challenge Overview](#challenge-overview)
2. [Fragment Solutions](#fragment-solutions)
3. [Complete Docker Compose Solution](#complete-docker-compose-solution)
4. [Final Flag](#final-flag)
5. [Step-by-Step Walkthrough](#step-by-step-walkthrough)
6. [Common Mistakes](#common-mistakes)

---

## Challenge Overview

Students must discover 4 fragments hidden across different Docker observation methods, reconstruct the complete `docker-compose.yml`, and spawn both quantum states to retrieve the flag.

### Fragment Distribution

| Fragment | Location | Method | Difficulty | Contains |
|----------|----------|--------|------------|----------|
| 1 | Container logs | `docker logs` | Easy | `state-alive` service definition |
| 2 | Image labels | `docker inspect` | Medium | Environment vars for `state-alive` |
| 3 | Encrypted label | `docker inspect` + decrypt | Hard | Labels + `state-dead` service |
| 4 | Deleted file in layer | `dive`/`docker save` | Very Hard | Environment vars for `state-dead` |

---

## Fragment Solutions

### Fragment 1: Docker Logs (Easy)

**Command:**
```bash
docker logs schrodingers-whale
```

**Output Contains:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐋 Quantum Fragment #1 detected in temporal stream:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ICBzdGF0ZS1hbGl2ZToKICAgIGltYWdlOiBzY2hyb2RpbmdlcnMtd2hhbGU6YWxpdmU=

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Also provides the decryption key:**
```
⚛️  Observer credentials: quantum_observer_2025
```

**Decoding:**
```bash
echo "ICBzdGF0ZS1hbGl2ZToKICAgIGltYWdlOiBzY2hyb2RpbmdlcnMtd2hhbGU6YWxpdmU=" | base64 -d
```

**Decoded Result:**
```yaml
  state-alive:
    image: schrodingers-whale:alive
```

---

### Fragment 2: Docker Inspect Labels (Medium)

**Command:**
```bash
docker inspect schrodingers-whale | grep quantum
```

Or more specifically:
```bash
docker inspect schrodingers-whale --format='{{.Config.Labels}}'
```

**Output Contains:**
```
quantum.fragment.2:ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA==
```

**Decoding:**
```bash
echo "ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA==" | base64 -d
```

**Decoded Result:**
```yaml
    environment:
      - QUANTUM_STATE=ALIVE
    profiles:
      - collapsed
```

---

### Fragment 3: Encrypted Label (Hard)

**Command:**
```bash
docker inspect schrodingers-whale --format='{{.Config.Labels}}' | grep encrypted
```

**Output Contains:**
```
quantum.encrypted.fragment:8bd7cf96ac1ede8c1d85dd2d155400902871ed7b6fd26e094a05992d059cf587a6dcd885a934f09120afcd2b2c1c17b73b769d2c45ff7902453f9a3202f8e19aa6d3db85bf1ef08c1eace4153f6d2ebc2875c0687fc64b02493f992f38f9db8ba0a6dc818734c2882786c62a121c07b30375f92a7cd679065c17e668
```

**Key (from Fragment 1 logs):**
```
quantum_observer_2025
```

**Decryption Method:**
This fragment uses two-layer encryption:
1. XOR encryption with SHA256(key)
2. Base64 encoding

Students can use the provided `decrypt.sh` script:

```bash
./decrypt.sh '8bd7cf96ac1ede8c1d85dd2d155400902871ed7b6fd26e094a05992d059cf587a6dcd885a934f09120afcd2b2c1c17b73b769d2c45ff7902453f9a3202f8e19aa6d3db85bf1ef08c1eace4153f6d2ebc2875c0687fc64b02493f992f38f9db8ba0a6dc818734c2882786c62a121c07b30375f92a7cd679065c17e668' 'quantum_observer_2025'
```

**Manual Decryption (if they want to script it themselves):**

```bash
# 1. Get SHA256 of key
KEY_HASH=$(echo -n "quantum_observer_2025" | sha256sum | cut -d' ' -f1)

# 2. XOR decrypt (complex - see decrypt.sh for full implementation)
# 3. Base64 decode the result
```

**Decoded Result:**
```yaml
    labels:
      - quantum.entangled=true
  state-dead:
    image: schrodingers-whale:dead
```

---

### Fragment 4: Deleted File in Docker Layer (Very Hard)

This is the most challenging fragment. The file `/tmp/.quantum_state_dead` was copied to the image, then deleted, but still exists in the Docker layer.

**Method 1: Using `dive`**

```bash
dive schrodingers-whale:latest
```

**Steps in dive:**
1. Navigate through layers (arrow keys)
2. Find the layer: `COPY fragments/state_dead.yml /tmp/.quantum_state_dead`
3. Press `Tab` to switch to file view
4. Navigate to `/tmp/` and see `.quantum_state_dead`
5. Note the layer hash (shown at bottom)
6. Exit dive (`Ctrl+C`)

**Note:** `dive` shows the file exists but doesn't display contents directly.

**Method 2: Using `docker save` (Complete Solution)**

```bash
# Step 1: Export the image
docker save schrodingers-whale:latest -o whale.tar

# Step 2: Extract
tar -xf whale.tar

# Step 3: Search all layer blobs for the file
for blob in blobs/sha256/*; do
    if tar -tf "$blob" 2>/dev/null | grep -q "quantum_state_dead"; then
        echo "✓ Found in blob: $(basename $blob)"
        FOUND_BLOB="$blob"
        break
    fi
done

# Step 4: Extract that specific layer
tar -xf "$FOUND_BLOB" tmp/.quantum_state_dead

# Step 5: Read the file
cat tmp/.quantum_state_dead
```

**One-Liner Solution:**
```bash
docker save schrodingers-whale:latest -o whale.tar && \
tar -xf whale.tar && \
for blob in blobs/sha256/*; do 
    if tar -tf "$blob" 2>/dev/null | grep -q "quantum_state_dead"; then 
        tar -xf "$blob" tmp/.quantum_state_dead 2>/dev/null
        cat tmp/.quantum_state_dead
        break
    fi
done
```

**File Contents:**
```yaml
environment:
- QUANTUM_STATE=DEAD
profiles:
- collapsed
labels:
- quantum.entangled=true
```

**Formatted for compose:**
```yaml
    environment:
      - QUANTUM_STATE=DEAD
    profiles:
      - collapsed
    labels:
      - quantum.entangled=true
```

---

## Complete Docker Compose Solution

After collecting and decoding all fragments, students must reconstruct the complete `docker-compose.yml`:

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

**Note:** The image names should match wherever the images were pushed (e.g., `your-dockerhub-username/schrodingers-whale:latest`).

---

## Final Flag

### Collapsing the Wave Function

Once students have the complete `docker-compose.yml`, they must spawn both quantum states:

```bash
docker-compose --profile collapsed up -d
```

This spawns two additional containers:
- `state-alive`
- `state-dead`

### Retrieving Flag Parts

**Flag Part 1 (from state-alive):**
```bash
docker logs state-alive
```

**Output:**
```
╔════════════════════════════════════════════════╗
║   STATE: ALIVE 🐋✨                           ║
╚════════════════════════════════════════════════╝

The wave function has collapsed.
This is the eigenstate where the whale survives.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FLAG PART 1:
FLAG{the_whale_is_not_alive_nor_dead_
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Flag Part 2 (from state-dead):**
```bash
docker logs state-dead
```

**Output:**
```
╔════════════════════════════════════════════════╗
║   STATE: DEAD 🐋💀                            ║
╚════════════════════════════════════════════════╝

The wave function has collapsed.
This is the eigenstate where the whale perishes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FLAG PART 2:
until_observed_67}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Complete Flag

```
FLAG{the_whale_is_not_alive_nor_dead_until_observed_67}
```

---

## Step-by-Step Walkthrough

### Phase 1: Initial Setup (2 minutes)
1. Extract challenge files
2. Navigate to challenge directory
3. Run `docker-compose up -d`
4. Verify container is running: `docker ps`

### Phase 2: Fragment 1 - Docker Logs (5 minutes)
1. Run `docker logs schrodingers-whale`
2. Read the output and find Fragment #1 (base64 string)
3. Note the decryption key: `quantum_observer_2025`
4. Decode base64: `echo "ICBzdGF0ZS1hbGl2ZToKICAgIGltYWdlOiBzY2hyb2RpbmdlcnMtd2hhbGU6YWxpdmU=" | base64 -d`
5. Get `state-alive` service definition

### Phase 3: Fragment 2 - Docker Inspect (5-10 minutes)
1. Run `docker inspect schrodingers-whale`
2. Search for quantum labels: `docker inspect schrodingers-whale | grep quantum`
3. Find `quantum.fragment.2` with base64 value
4. Decode: `echo "ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA==" | base64 -d`
5. Get environment and profiles for `state-alive`

### Phase 4: Fragment 3 - Encrypted Label (10-15 minutes)
1. Find `quantum.encrypted.fragment` in inspect output
2. Recall the decryption key from Fragment 1 logs
3. Use provided decrypt.sh: `./decrypt.sh '<hex_string>' 'quantum_observer_2025'`
4. Get labels and `state-dead` service definition

### Phase 5: Fragment 4 - Deleted Layer (15-30 minutes)
1. Realize there's missing information (environment for `state-dead`)
2. Check for hints about layers/dive in logs or labels
3. Option A: Use `dive schrodingers-whale:latest` to explore layers
4. Option B: Use `docker save` method to extract layers
5. Find `/tmp/.quantum_state_dead` in a layer before it was deleted
6. Extract and read the file
7. Get environment and other config for `state-dead`

### Phase 6: Reconstruction (5 minutes)
1. Combine all four fragments
2. Reconstruct complete `docker-compose.yml`
3. Understand the `profiles: collapsed` mechanism
4. Save the file

### Phase 7: Wave Function Collapse (2 minutes)
1. Run `docker-compose --profile collapsed up -d`
2. Verify both new containers spawned: `docker ps`
3. See `state-alive` and `state-dead` containers running

### Phase 8: Flag Retrieval (3 minutes)
1. Run `docker logs state-alive` → Get first part
2. Run `docker logs state-dead` → Get second part
3. Combine both parts
4. Submit complete flag

**Total Time: 35-50 minutes**

---

## Common Mistakes

### Mistake 1: Using `docker exec`
**What they do:**
```bash
docker exec -it schrodingers-whale sh
```

**Why it's wrong:** This defeats the purpose of the challenge. All observation must be external.

**Solution:** Remind them to read the rules - no entering containers.

---

### Mistake 2: Not Decoding Base64
**What they do:** Try to use base64 strings directly in compose file

**Why it's wrong:** Fragments are encoded and must be decoded first

**Solution:** Provide hint about `base64 -d` command

---

### Mistake 3: Missing the Decryption Key
**What they do:** Can't decrypt Fragment 3

**Why it's wrong:** They didn't notice the key in Fragment 1 logs

**Solution:** Point them back to the logs output - key is clearly labeled as "Observer credentials"

---

### Mistake 4: Wrong Image Names
**What they do:**
```yaml
image: schrodingers-whale:alive
```

**Why it's wrong:** If images were pushed to Docker Hub, they need the full registry path

**Solution:** Images should be `your-dockerhub-username/schrodingers-whale:alive` or wherever they were pushed

---

### Mistake 5: Not Using Profiles
**What they do:**
```bash
docker-compose up -d
```
(After reconstructing the file)

**Why it's wrong:** This only starts the base container. The `state-alive` and `state-dead` services use profiles.

**Solution:** Must use `docker-compose --profile collapsed up -d`

---

### Mistake 6: Can't Find Fragment 4
**What they do:** Get stuck after finding 3 fragments

**Why it's wrong:** Don't know about Docker layer forensics

**Hints to provide progressively:**
1. "Check the hints in the labels"
2. "Have you tried `dive`?"
3. "Files that are deleted in Docker aren't really gone"
4. "Try `docker save` to export the image"

---

### Mistake 7: Incomplete Compose File
**What they do:** Missing parts like `profiles`, `labels`, or `environment` variables

**Why it's wrong:** Didn't collect all fragments or didn't decode everything

**Solution:** Have them verify they have 4 complete fragments and check each service has all required fields

---

### Mistake 8: dive Not Installed
**What they do:** Try to use dive but command not found

**Solution:** Provide installation instructions:
```bash
# macOS
brew install dive

# Linux
sudo dnf install dive  # Fedora/RHEL
sudo apt install dive  # Debian/Ubuntu
```

Or point to: https://github.com/wagoodman/dive/releases

---

## Answer Key Summary

### All Fragments (Decoded)

**Fragment 1:**
```yaml
  state-alive:
    image: schrodingers-whale:alive
```

**Fragment 2:**
```yaml
    environment:
      - QUANTUM_STATE=ALIVE
    profiles:
      - collapsed
```

**Fragment 3:**
```yaml
    labels:
      - quantum.entangled=true
  state-dead:
    image: schrodingers-whale:dead
```

**Fragment 4:**
```yaml
    environment:
      - QUANTUM_STATE=DEAD
    profiles:
      - collapsed
    labels:
      - quantum.entangled=true
```

### Decryption Key
```
quantum_observer_2025
```

### Final Flag
```
FLAG{the_whale_is_not_alive_nor_dead_until_observed_67}
```

---

## Verification Checklist

Use this to verify a student's solution:

- [ ] Found Fragment 1 from logs
- [ ] Decoded Fragment 1 base64
- [ ] Found Fragment 2 in inspect labels
- [ ] Decoded Fragment 2 base64
- [ ] Found Fragment 3 encrypted label
- [ ] Used decryption key correctly
- [ ] Decoded Fragment 3
- [ ] Found Fragment 4 in deleted layer using dive or docker save
- [ ] Reconstructed complete docker-compose.yml
- [ ] All services present (3 total)
- [ ] All environment variables correct
- [ ] Profiles configured correctly
- [ ] Labels present
- [ ] Successfully ran `docker-compose --profile collapsed up -d`
- [ ] Both state containers spawned
- [ ] Retrieved flag part 1 from state-alive
- [ ] Retrieved flag part 2 from state-dead
- [ ] Combined flag correctly
- [ ] Submitted complete flag

---

**End of Solutions Guide**