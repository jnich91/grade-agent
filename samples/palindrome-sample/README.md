# Palindrome Sample (Java 21 + Maven)

This is a small, realistic assignment used to bootstrap the grading pipeline.

## Spec
- Class: `edu.example.grading.Palindrome`
- Method: `public static boolean isPalindrome(String s)`
- Case-insensitive, ignore non-alphanumeric characters
- `""` and single-char strings are palindromes
- `null` → `IllegalArgumentException`

## Run
```bash
mvn -q -DskipTests=false test
```
Reports appear in `target/surefire-reports/`.
