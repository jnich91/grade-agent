package edu.example.grading;

public final class Palindrome {

    private Palindrome() { /* utility class */ }

    /**
     * Returns true iff the input string is a palindrome when compared
     * case-insensitively and with all non-alphanumeric characters removed.
     * Empty and single-character strings are palindromes.
     * @throws IllegalArgumentException if s is null
     */
    public static boolean isPalindrome(String s) {
        if (s == null) {
            throw new IllegalArgumentException("input must not be null");
        }
        // Keep only letters and digits; normalize case
        StringBuilder cleaned = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (Character.isLetterOrDigit(c)) {
                cleaned.append(Character.toLowerCase(c));
            }
        }
        int i = 0, j = cleaned.length() - 1;
        while (i < j) {
            if (cleaned.charAt(i) != cleaned.charAt(j)) return false;
            i++; j--;
        }
        return true;
    }
}
