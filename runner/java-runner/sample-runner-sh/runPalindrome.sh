#!/usr/bin/env bash
set -euo pipefail

# Variables you can adjust
STUDENT_ID="s123"
ASSIGNMENT_ID="palindrome-a"

docker run --rm \
  --network=none --cpus="1.0" --memory="1g" --pids-limit=256 \
  --read-only --tmpfs "/tmp:rw,nosuid,nodev,size=64m" \
  --user 65532:65532 --cap-drop=ALL \
  -e ASSIGNMENT_ID="$ASSIGNMENT_ID" \
  -v "$HOME/grading/work/submissions/$STUDENT_ID:/work/input:ro" \
  -v "$HOME/grading/work/artifacts/$STUDENT_ID:/work/output:rw" \
  grading-java-runner:palindrome

