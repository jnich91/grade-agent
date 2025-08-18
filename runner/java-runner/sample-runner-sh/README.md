# Grading Java Runner – Examples

Runners compile and test Java assignments in an isolated Docker container.  
Below are example commands to run different graders:

>[!CAUTION] 
>Not all scripts have been fully tested.

---

## Palindrome Assignment

### macOS / Linux

```bash
docker run --rm \
  --network=none --cpus="1.0" --memory="1g" --pids-limit=256 \
  --read-only --tmpfs "/tmp:rw,nosuid,nodev,size=64m" \
  --user 65532:65532 --cap-drop=ALL \
  -e ASSIGNMENT_ID="palindrome-a" \
  -v "$HOME/grading/work/submissions/s123:/work/input:ro" \
  -v "$HOME/grading/work/artifacts/s123:/work/output:rw" \
  grading-java-runner:palindrome
```

---

### Windows (via WSL, files in Linux home)

```bash
docker run --rm \
  -e ASSIGNMENT_ID="palindrome-a" \
  -v "$HOME/grading/work/submissions/s123:/work/input:ro" \
  -v "$HOME/grading/work/artifacts/s123:/work/output:rw" \
  grading-java-runner:palindrome
```

---

### Windows (via WSL, files in Windows home)

```bash
docker run --rm \
  -e ASSIGNMENT_ID="palindrome-a" \
  -v "/mnt/c/Users/<You>/grading/work/submissions/s123:/work/input:ro" \
  -v "/mnt/c/Users/<You>/grading/work/artifacts/s123:/work/output:rw" \
  grading-java-runner:palindrome
```

---

## Convenience Script

Save as `run-palindrome.sh`:

```bash
#!/usr/bin/env bash
docker run --rm \
  --network=none --cpus="1.0" --memory="1g" --pids-limit=256 \
  --read-only --tmpfs "/tmp:rw,nosuid,nodev,size=64m" \
  --user 65532:65532 --cap-drop=ALL \
  -e ASSIGNMENT_ID="${2:-palindrome-a}" \
  -v "$HOME/grading/work/submissions/${1:-s123}:/work/input:ro" \
  -v "$HOME/grading/work/artifacts/${1:-s123}:/work/output:rw" \
  grading-java-runner:palindrome
```

Run:

```bash
./run-palindrome.sh s123 palindrome-a
```

---
