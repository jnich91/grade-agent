** Build from root **

docker build -t grading-java-runner:palindrome -f runner/java-runner/Dockerfile .

# run with /work as tmpfs, and bind-mount subdirs
docker run --rm \
  --network=none --cpus="1.0" --memory="1g" --pids-limit=256 \
  --read-only \
  --tmpfs "/tmp:rw,nosuid,nodev,size=64m" \
  --tmpfs "/work:rw,nosuid,nodev,size=64m" \
  --user 65532:65532 --cap-drop=ALL \
  -e ASSIGNMENT_ID="palindrome-a" \
  -v "$HOME/grading/work/submissions/s123/input:/work/input:ro" \
  -v "$HOME/grading/work/artifacts/s123/output:/work/output:rw" \
  grading-java-runner:palindrome


mkdir -p "$HOME/grading/work/submissions/s123/input"
mkdir -p "$HOME/grading/work/artifacts/s123/output"