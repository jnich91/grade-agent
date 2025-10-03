** Build from root **

docker build -t grading-java-runner:palindrome -f runner/java-runner/Dockerfile .

** Setup directories **

mkdir -p "$HOME/grading/work/submissions/student1/input/student"
mkdir -p "$HOME/grading/work/artifacts/student1/output"

** Run with reactor mode (students submit only .java files) **

# Student files go in input/student/ subdirectory
# Tests are baked into the Docker image at /work/input/tests

docker run --rm \
  --network=none --cpus="1.0" --memory="1g" --pids-limit=256 \
  --tmpfs "/tmp:rw,nosuid,nodev,exec,size=64m" \
  --tmpfs "/work:rw,nosuid,nodev,size=64m,uid=65532,gid=65532" \
  --user 65532:65532 --cap-drop=ALL \
  -e ASSIGNMENT_ID="palindrome-a" \
  -v "$HOME/grading/work/submissions/student1/input:/work/input:ro" \
  -v "$HOME/grading/work/artifacts/student1/output:/work/output:rw" \
  grading-java-runner:palindrome

** Check results **

cat ~/grading/work/artifacts/student1/output/mvn.log
grep -E "Tests run:|BUILD" ~/grading/work/artifacts/student1/output/mvn.log