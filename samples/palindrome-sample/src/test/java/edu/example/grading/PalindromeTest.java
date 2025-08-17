package edu.example.grading;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PalindromeTest {

    @Test
    void basicTrueCases() {
        assertTrue(Palindrome.isPalindrome("racecar"));
        assertTrue(Palindrome.isPalindrome("RaceCar"));
        assertTrue(Palindrome.isPalindrome("abba"));
    }

    @Test
    void basicFalseCases() {
        assertFalse(Palindrome.isPalindrome("hello"));
        assertFalse(Palindrome.isPalindrome("world"));
        assertFalse(Palindrome.isPalindrome("ab"));
    }

    @Test
    void punctuationAndWhitespace() {
        assertTrue(Palindrome.isPalindrome("A man, a plan, a canal: Panama"));
        assertTrue(Palindrome.isPalindrome("No 'x' in Nixon"));
        assertTrue(Palindrome.isPalindrome("Never odd or even."));
    }

    @Test
    void edgeCases() {
        assertTrue(Palindrome.isPalindrome(""));
        assertTrue(Palindrome.isPalindrome("a"));
        assertTrue(Palindrome.isPalindrome("0"));
    }

    @Test
    void nullInputThrows() {
        assertThrows(IllegalArgumentException.class, () -> Palindrome.isPalindrome(null));
    }
}
