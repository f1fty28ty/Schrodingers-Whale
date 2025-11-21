# Fragment 5 - Complete Walkthrough
## Finding the Deleted File in Docker Layers

Fragment 5 is the most challenging fragment as it requires Docker forensics skills to extract a file that was deleted from the final container filesystem but still exists in the image layers.

---

## Method 1: Using `dive` to Explore Layers

### Step 1: Launch dive
```bash
dive f1fty28ty/schrodingers-whale:latest
```

### Step 2: Navigate the Interface
When `dive` opens, you'll see two panels:
- **Left Panel**: Layer list (image build history)
- **Right Panel**: File tree for the selected layer

**Key Controls:**
- `Tab` - Switch between panels
- `↑/↓` - Navigate items
- `Ctrl+A` - Toggle showing added files
- `Ctrl+R` - Toggle showing removed files
- `Ctrl+U` - Toggle showing unmodified files
- `Space` - Collapse/expand all directories

### Step 3: Find the COPY Layer
In the **Layers panel** (left side), scroll down until you find:
```
COPY fragments/state_dead.yml /tmp/.quantum_state_dead # buildkit
```

This layer should be small (around 89 bytes).

### Step 4: View the File
1. Select that COPY layer with arrow keys
2. Press `Tab` to switch to the **Layer Contents panel** (right)
3. Navigate to `/tmp/` directory
4. You should see `.quantum_state_dead` listed

**Note:** `dive` shows you the file EXISTS but doesn't let you read its contents directly.

### Step 5: Note the Layer Information
While still in `dive`, look at the bottom of the screen for the layer information. You'll see something like:
```
Layer: 18/20  Size: 89 B
```

The important part is identifying which layer number this is.

### Step 6: Find the Next Layer (DELETE)
Use arrow keys to go DOWN one layer. You should see:
```
RUN /bin/sh -c rm /tmp/.quantum_state_dead # buildkit
```

In the **Layer Contents panel**, if you press `Ctrl+R` (show removed files), you'll see the file marked as removed.

**This confirms the file was deleted but still exists in the previous layer!**

### Step 7: Exit dive
Press `Ctrl+C` to exit.

---

## Method 2: Using `docker save` to Extract the Layer

Now that we know the file exists, let's extract it.

### Step 1: Save the Image
```bash
docker save f1fty28ty/schrodingers-whale:latest -o whale.tar
```

This creates a tar file containing all image layers.

### Step 2: Extract the Tar
```bash
tar -xf whale.tar
```

This creates a directory structure like:
```
blobs/
  sha256/
    <hash1>
    <hash2>
    ...
index.json
manifest.json
oci-layout
```

### Step 3: Search for the File in All Layers
Use this command to search through all layer tar files:

```bash
for blob in blobs/sha256/*; do
    echo "Checking blob: $(basename $blob)"
    if tar -tf "$blob" 2>/dev/null | grep -q "quantum_state_dead"; then
        echo "✓ FOUND in blob: $(basename $blob)"
        echo "File path in layer:"
        tar -tf "$blob" 2>/dev/null | grep quantum_state_dead
    fi
done
```

**Output will look like:**
```
Checking blob: 0223b0b36394...
Checking blob: 07e7e77e7d64...
...
Checking blob: 154fe83b2b45...
✓ FOUND in blob: 154fe83b2b45a27a1364b9f93cecb84c6ba2147ab5a5fe1935d0d9b3b20aee6d
File path in layer:
tmp/.quantum_state_dead
```

### Step 4: Extract That Specific Layer
Once you've identified the blob hash, extract it:

```bash
BLOB_HASH="154fe83b2b45a27a1364b9f93cecb84c6ba2147ab5a5fe1935d0d9b3b20aee6d"

# Create extraction directory
mkdir -p extracted_layer

# Extract the layer
tar -xf "blobs/sha256/$BLOB_HASH" -C extracted_layer

# View the file
cat extracted_layer/tmp/.quantum_state_dead
```

### Step 5: Get Fragment 5
```bash
cat extracted_layer/tmp/.quantum_state_dead
```

**Output:**
```yaml
environment:
- QUANTUM_STATE=DEAD
profiles:
- collapsed
labels:
- quantum.entangled=true
```

---

## Method 3: One-Liner Search Script

For convenience, you can use this one-liner:

```bash
# Save and extract image
docker save f1fty28ty/schrodingers-whale:latest -o whale.tar && \
tar -xf whale.tar && \

# Find and extract the fragment
for blob in blobs/sha256/*; do 
    if tar -tf "$blob" 2>/dev/null | grep -q "quantum_state_dead"; then 
        echo "Found in: $(basename $blob)"
        tar -xf "$blob" tmp/.quantum_state_dead 2>/dev/null
        echo "=== Fragment 5 ==="
        cat tmp/.quantum_state_dead
        break
    fi
done
```

---

## Understanding What Happened

### Why does this work?

Docker images are built in **layers**. Each `RUN`, `COPY`, `ADD` command creates a new layer.

**Layer Stack:**
```
Layer 1: Base alpine image
Layer 2: Install dependencies
...
Layer N:   COPY fragments/state_dead.yml /tmp/.quantum_state_dead  ← File exists here
Layer N+1: RUN rm /tmp/.quantum_state_dead                        ← File deleted here
...
Final layer: Container filesystem (file doesn't exist)
```

When you run the container, you see the **final merged result** of all layers. The file was deleted in Layer N+1, so it doesn't appear in the final filesystem.

However, **Layer N still contains the file** because layers are immutable. Once created, a layer never changes.

### Docker Layer Architecture

Each layer is stored as a tar file in the image. When Docker builds:
1. `COPY` command → Creates new layer with file added
2. `RUN rm` command → Creates new layer with deletion marker (whiteout file)
3. Final view → Merge all layers, apply deletions

Using `docker save`, we can extract individual layers and see files that were later "deleted."

---

## Complete Fragment 5 Workflow

```bash
# 1. Use dive to confirm file exists (optional but helpful)
dive f1fty28ty/schrodingers-whale:latest
# Navigate to find COPY layer, see file exists

# 2. Export the image
docker save f1fty28ty/schrodingers-whale:latest -o whale.tar

# 3. Extract
tar -xf whale.tar

# 4. Search all layers
for blob in blobs/sha256/*; do 
    tar -tf "$blob" 2>/dev/null | grep quantum_state_dead && \
    echo "Found in: $blob"
done

# 5. Extract the specific layer (replace HASH with actual hash found)
tar -xf blobs/sha256/<HASH> tmp/.quantum_state_dead

# 6. Read Fragment 5
cat tmp/.quantum_state_dead
```

---

## Tips for Players

1. **Use `dive` first** - It's visual and helps you understand the layer structure
2. **Pay attention to file sizes** - The layer with the COPY is only 89 bytes
3. **Look for patterns** - The COPY and DELETE are in consecutive layers
4. **Remember**: Deleted files in Docker aren't truly deleted, just hidden in the final view
5. **The hint label** tells you exactly what to look for: `quantum_state_dead`

---

## Expected Time

- With `dive` experience: 10-15 minutes
- Without `dive` experience: 20-30 minutes
- First-time Docker forensics: 30-45 minutes

This is intentionally the hardest fragment to teach real Docker security and forensics skills!