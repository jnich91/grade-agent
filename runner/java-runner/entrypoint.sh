#!/usr/bin/env sh
# entrypoint.sh — grading-java-runner
# - Strict shell: fail fast, log breadcrumbs
# - Works with read-only rootfs; expects writable /work and /tmp
# - Offline Maven (-o) using a prewarmed local repo at /opt/m2 (baked into the image)
# - Detects layout (single module or reactor student+tests)
# - NORMALIZES student sources into src/main/java based on `package` declarations
# - Always writes mvn.log and propagates Maven exit code

set -eu

LOG="/work/output/mvn.log"
META="/work/output/run.meta"
ASSIGNMENT_ID="${ASSIGNMENT_ID:-unknown}"
MVN_REPO="${MVN_REPO:-/opt/m2}"
MVN_ARGS="-B -o -Dmaven.repo.local=${MVN_REPO}"

# ---------- helpers ----------
note() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" >> "$META"; }
finish() {
  code=$?
  note "runner_exit_code=$code"
  exit "$code"
}
trap finish EXIT

mkdir -p /work/output || true

# ---------- breadcrumbs ----------
note "assignment=${ASSIGNMENT_ID}"
note "uid_gid=$(id -u):$(id -g)"
note "whoami=$(whoami)"
note "pwd=$(pwd)"

note "ls_root_begin"
ls -la / >>"$META" 2>&1 || true
note "ls_root_end"

note "ls_work_begin"
ls -la /work >>"$META" 2>&1 || true
note "ls_work_end"

note "env_begin"
env | sort >>"$META"
note "env_end"

# ---------- verify tools and start mvn.log (never empty) ----------
{
  echo "== java -version =="
  java -version
  echo
  echo "== mvn -v =="
  mvn -v
  echo
} > "$LOG" 2>&1 || true

# ---------- layout detection ----------
# Cases:
#  A) /work/input/pom.xml (single-module)
#  B) /work/input/{student,pom.xml} and /work/input/{tests,pom.xml} (reactor)
#  C) Discover exactly one pom.xml under /work/input (depth<=2)

PROJECT_ROOT=""
MODE="single"

if [ -f /work/input/pom.xml ]; then
  PROJECT_ROOT="/work/input"
  MODE="single"
  note "layout=single project_root=$PROJECT_ROOT"
elif [ -f /work/input/tests/pom.xml ] && [ -f /work/input/student/pom.xml ]; then
  MODE="reactor"
  rm -f /work/student /work/tests 2>/dev/null || true
  ln -s /work/input/student /work/student
  ln -s /work/input/tests   /work/tests
  PROJECT_ROOT="/work"
  if [ ! -f /work/pom.xml ]; then
    cat > /work/pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>edu.cmu.cs</groupId>
  <artifactId>reactor</artifactId>
  <version>1.0.0</version>
  <packaging>pom</packaging>
  <modules>
    <module>student</module>
    <module>tests</module>
  </modules>
</project>
EOF
  fi
  note "layout=reactor project_root=$PROJECT_ROOT modules=student,tests"
else
  POM_COUNT="$(find /work/input -maxdepth 2 -type f -name pom.xml | wc -l | tr -d ' ')"
  if [ "$POM_COUNT" = "1" ]; then
    PROJECT_ROOT="$(dirname "$(find /work/input -maxdepth 2 -type f -name pom.xml)")"
    MODE="single"
    note "layout=single_discovered project_root=$PROJECT_ROOT"
  else
    note "error=no_pom_found_under_/work/input pom_count=$POM_COUNT"
    echo "No usable pom.xml found under /work/input (found: $POM_COUNT)" >> "$LOG"
    exit 2
  fi
fi

# ---------- package-aware student source normalization ----------
# Move arbitrary student .java files into Maven layout based on `package` lines.
normalize_student_sources() {
  src_scan_root="$1"     # path where raw student .java files live
  module_root="$2"       # module root where we must create src/main/java
  dest_root="$module_root/src/main/java"

  # If a valid Maven layout already exists with .java files, leave it alone.
  if [ -d "$dest_root" ] && find "$dest_root" -type f -name '*.java' -quit 2>/dev/null; then
    note "normalize_skip=already_structured module_root=$module_root"
    return 0
  fi

  # Wipe and recreate dest root
  rm -rf "$dest_root" 2>/dev/null || true
  mkdir -p "$dest_root"

  # Collect all .java files (flat or nested)
  found_any="false"
  find "$src_scan_root" -type f -name '*.java' 2>/dev/null | while read -r f; do
    found_any="true"
    # Extract 'package ...;' (first match), strip semicolon
    pkg="$(grep -E '^[[:space:]]*package[[:space:]]+[A-Za-z0-9_.]+' "$f" | head -n1 | awk '{print $2}' | tr -d ';' || true)"
    if [ -z "${pkg:-}" ]; then
      dest_dir="$dest_root"
    else
      dest_dir="$dest_root/$(echo "$pkg" | tr '.' '/')"
    fi
    mkdir -p "$dest_dir"
    cp "$f" "$dest_dir/"
    note "normalized file=$(basename "$f") pkg=${pkg:-<default>} dest=$dest_dir"
  done

  # If we didn't find any .java files, log it (not a hard error—maybe it's a prebuilt jar assignment).
  if [ "$found_any" = "false" ]; then
    note "normalize_warning=no_java_files_found scan_root=$src_scan_root"
  fi
}

# Apply normalization depending on layout
if [ "$MODE" = "reactor" ]; then
  # Expect raw student files somewhere under /work/student (symlink to /work/input/student)
  normalize_student_sources "/work/student" "/work/student"
else
  # Single-module: place under PROJECT_ROOT (which contains pom.xml)
  # Assume raw student files are under PROJECT_ROOT or PROJECT_ROOT/student
  if [ -d "$PROJECT_ROOT/student" ]; then
    normalize_student_sources "$PROJECT_ROOT/student" "$PROJECT_ROOT"
  else
    normalize_student_sources "$PROJECT_ROOT" "$PROJECT_ROOT"
  fi
fi

# ---------- run maven ----------
cd "$PROJECT_ROOT"
note "cd_project_root=$(pwd)"

note "ls_project_begin"
ls -la >>"$META" 2>&1 || true
note "ls_project_end"

{
  echo "== Using Maven local repo at: ${MVN_REPO} =="
  echo "== Project root: $(pwd) (mode=${MODE}) =="
  echo
} >> "$LOG" 2>&1

if [ "$MODE" = "reactor" ]; then
  {
    echo "== mvn ${MVN_ARGS} -pl tests -am test =="
    mvn ${MVN_ARGS} -pl tests -am test
  } >> "$LOG" 2>&1
else
  {
    echo "== mvn ${MVN_ARGS} test =="
    mvn ${MVN_ARGS} test
  } >> "$LOG" 2>&1
fi

# ---------- copy surefire reports to /work/output ----------
copy_reports() {
  from_dir="$1"
  name="$2"
  if [ -d "$from_dir/target/surefire-reports" ]; then
    mkdir -p "/work/output/surefire/$name" || true
    cp -R "$from_dir/target/surefire-reports/." "/work/output/surefire/$name/" 2>/dev/null || true
    note "copied_surefire_from=$from_dir to=/work/output/surefire/$name"
  fi
}

if [ "$MODE" = "reactor" ]; then
  copy_reports "/work/tests" "tests"
  copy_reports "/work/student" "student"
else
  copy_reports "$(pwd)" "project"
fi

note "done=true"
# (exit code handled by trap)
