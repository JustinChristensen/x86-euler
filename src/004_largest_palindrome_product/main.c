#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

bool is_palindrome(char *s, unsigned n) {
    if (!n) return false;

    unsigned h = n >> 1,
             l = n & 1 ? h : h - 1;

    do {
        if (s[l] != s[h]) return false;
        n = l;
    } while (l--, h++, n);

    return true;
}

unsigned largest_palindrome() {
    unsigned max = 0;

    for (unsigned i = 999; i > 0; i--)
        for (unsigned j = i; j > 0; j--) {
            char buf[16];
            unsigned n = i * j;
            int blen = snprintf(buf, sizeof buf, "%u", n);

            if (is_palindrome(buf, blen)) {
                max = max >= n ? max : n;
            }
        }

    return max;
}

int main() {
    printf("%u\n", largest_palindrome());
    return 0;
}

