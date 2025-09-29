package edu.example.grading;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PalindromeTest {

    @Test
    void testEmptyString() {
        assertTrue(Palindrome.isPalindrome(""), "empty string is a palindrome");
    }

    @Test
    void testWhitespaceOnly() {
        assertTrue(Palindrome.isPalindrome("   "), "whitespace only should be a palindrome");
    }

    @Test
    void testSimplePalindromes() {
        assertTrue(Palindrome.isPalindrome("a"));
        assertTrue(Palindrome.isPalindrome("abba"));
        assertTrue(Palindrome.isPalindrome("aba"));
        assertTrue(Palindrome.isPalindrome("racecar"));
    }

    @Test
    void testSimpleNonPalindromes() {
        assertFalse(Palindrome.isPalindrome("ab"));
        assertFalse(Palindrome.isPalindrome("hello"));
        assertFalse(Palindrome.isPalindrome("world"));
    }

    @Test
    void testCaseInsensitivity() {
        assertTrue(Palindrome.isPalindrome("RaceCar"));
        assertTrue(Palindrome.isPalindrome("AbBa"));
    }

    @Test
    void testIgnoresNonAlphanumeric() {
        assertTrue(Palindrome.isPalindrome("A man, a plan, a canal: Panama"));
        assertTrue(Palindrome.isPalindrome("No 'x' in Nixon"));
        assertTrue(Palindrome.isPalindrome("Was it a car or a cat I saw?"));
    }

    @Test
    void testLongPalindrome() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 5000; i++) {
            sb.append("ab");
        }
        String base = sb.toString();
        String palindrome = base + "x" + new StringBuilder(base).reverse();
        assertTrue(Palindrome.isPalindrome(palindrome));
    }

    @Test
    void testLongNonPalindrome() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 10000; i++) {
            sb.append("a");
        }
        sb.append("b"); // break palindrome
        assertFalse(Palindrome.isPalindrome(sb.toString()));
    }
    @Test
    void nullInputThrows() {
        assertThrows(IllegalArgumentException.class, () -> Palindrome.isPalindrome(null));
    }
}
