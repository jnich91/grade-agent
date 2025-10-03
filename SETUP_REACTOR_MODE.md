# Reactor Mode Setup - Students Submit Only .java Files

## What Changed

The Docker image now uses **reactor mode** where:
- **Instructor tests** are baked into the Docker image (fully controlled)
- **Students** only submit their `.java` files (no pom.xml, no tests)
- The entrypoint auto-generates a safe pom.xml for student code

## How to Rebuild

From your Mac terminal (repo root):

```bash
docker build -t grading-java-runner:palindrome -f runner/java-runner/Dockerfile .
```

## How to Create a Student Submission

Students now only need to submit their source files:

```bash
# Create student submission directory
mkdir -p ~/grading/work/submissions/student2/input/student
mkdir -p ~/grading/work/artifacts/student2/output

# Student puts only their Palindrome.java in the student/ subdirectory
cat > ~/grading/work/submissions/student2/input/student/Palindrome.java << 'EOF'
package edu.example.grading;

public class Palindrome {
    public static boolean isPalindrome(String s) {
        if (s == null) {
            throw new IllegalArgumentException("Input cannot be null");
        }
        StringBuilder cleaned = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (Character.isLetterOrDigit(c)) {
                cleaned.append(Character.toLowerCase(c));
            }
        }
        String str = cleaned.toString();
        int left = 0;
        int right = str.length() - 1;
        while (left < right) {
            if (str.charAt(left) != str.charAt(right)) {
                return false;
            }
            left++;
            right--;
        }
        return true;
    }
}
EOF
```

## How to Run Grading

```bash
docker run --rm \
  --network=none --cpus="1.0" --memory="1g" --pids-limit=256 \
  --tmpfs "/tmp:rw,nosuid,nodev,exec,size=64m" \
  --tmpfs "/work:rw,nosuid,nodev,size=64m,uid=65532,gid=65532" \
  --user 65532:65532 --cap-drop=ALL \
  -e ASSIGNMENT_ID="palindrome-a" \
  -v "$HOME/grading/work/submissions/student2/input:/work/input:ro" \
  -v "$HOME/grading/work/artifacts/student2/output:/work/output:rw" \
  grading-java-runner:palindrome
```

## Check Results

```bash
# View build and test output
cat ~/grading/work/artifacts/student2/output/mvn.log

# Quick summary
grep -E "Tests run:|BUILD" ~/grading/work/artifacts/student2/output/mvn.log

# View runtime metadata
cat ~/grading/work/artifacts/student2/output/run.meta

# View detailed test reports
ls ~/grading/work/artifacts/student2/output/surefire/
```

## Key Points

1. **Tests are in the image** - Students cannot modify or see them
2. **Student directory structure** - Must be `input/student/*.java`
3. **Package normalization** - The entrypoint reads package declarations and places files correctly
4. **No pom.xml needed** - Auto-generated safely by the entrypoint