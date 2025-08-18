#!/usr/bin/env bash
set -euo pipefail

# --- Paths ---
TEMPLATE=/template           # read-only instructor template (baked into image)
IN=/work/input               # mounted student sources (read-only)
OUT=/work/output             # mounted artifacts (read-write)
BUILD=/tmp/work              # writable build workspace (tmpfs with --tmpfs /tmp)

# --- Prep output dirs ---
mkdir -p "$OUT" "$OUT/surefire"

mkdir -p "$OUT/tmp"
export MAVEN_OPTS="-Djansi.enabled=false -Djansi.passthrough=true -Djansi.tmpdir=$OUT/tmp"

# --- Fresh build workspace in tmpfs ---
rm -rf "$BUILD" && mkdir -p "$BUILD"
# Copy template into writable area (do NOT modify /template directly)
cp -R "$TEMPLATE"/. "$BUILD"/

# Ensure source root exists
mkdir -p "$BUILD/src/main/java"

# --- Copy student sources ---
rm -rf "$BUILD/src/main/java" && mkdir -p "$BUILD/src/main/java"

found_any=false
while IFS= read -r -d '' f; do
  pkg=$(sed -n 's/^[[:space:]]*package[[:space:]]\+\([A-Za-z0-9_\.]\+\)[[:space:]]*;.*$/\1/p' "$f" | head -n1 || true)
  if [ -n "$pkg" ]; then
    pkgpath=${pkg//./\/}
    dest="$BUILD/src/main/java/$pkgpath/$(basename "$f")"
    mkdir -p "$(dirname "$dest")"
  else
    dest="$BUILD/src/main/java/$(basename "$f")"
  fi
  cp "$f" "$dest"
  found_any=true
done < <(find "$IN" -type f -name "*.java" -print0 2>/dev/null || true)

if [ "$found_any" = false ]; then
  echo "No .java files found in $IN" | tee "$OUT/mvn.log"
  {
    echo "runner_exit_code=2"
    echo "reason=no_java_files"
    echo "timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "$OUT/run.meta"
  exit 2
fi

# --- Run tests with strong defaults ---
MVN_FLAGS=(
  -o
  -q
  -f "$BUILD/pom.xml"
  -Dmaven.repo.local=/opt/m2repo
  -Djava.io.tmpdir=/tmp
  -Djansi.tmpdir="$OUT/tmp"
  -Djansi.force=false
  -DskipTests=false
  test
)

CODE=0
# 💡 New line to force fresh compile every run
rm -rf "$BUILD/target"

# Capture maven output to $OUT/mvn.log so host can inspect builds
if ! timeout 60s mvn "${MVN_FLAGS[@]}" >"$OUT/mvn.log" 2>&1; then
  CODE=$?
fi

# --- Export reports ---
if [ -d "$BUILD/target/surefire-reports" ]; then
  cp -R "$BUILD/target/surefire-reports/." "$OUT/surefire/" || true
fi

# --- Metadata ---
{
  echo "runner_exit_code=$CODE"
  echo "assignment=${ASSIGNMENT_ID:-unknown}"
  echo -n "java: " ; java -version 2>&1 | tr '\n' ' ' | sed 's/  */ /g'
  echo
  echo -n "mvn:  " ; mvn -v 2>&1 | head -n1
  echo "timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} > "$OUT/run.meta"

exit "$CODE"
