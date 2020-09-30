#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define N 600851475143

char *itoa(char *buf, size_t len, unsigned n) {
    if (len <= 1 || !buf) return NULL;

    char *s = &buf[len - 1];
    *s-- = '\0';

    do *s-- = '0' + n % 10;
    while (n /= 10);

    return ++s;
}

void fermats() {
    // a^2 - n = b^2
    unsigned long n = N,
                  a = ceil(sqrt(n)) - 1;
    double _b;

    do {
        a++;
        _b = sqrt(a * a - n);
    } while (ceil(_b) != _b);

    unsigned long b = _b;
    printf("%lu = %lu^2 - %lu^2\n", n, a, b);
    printf("%lu = %lu * %lu\n", n, a +  b, a - b);
}

void factors(unsigned long n) {
    unsigned long orig = n;
    unsigned long f = 2;

    printf("%lu ", 1UL);

    while (n > 1) {
        while (n % f != 0) f++;
        n = n / f;
        printf("%lu ", f);
    }

    printf("%lu\n", orig);
}

int main() {
    fermats();
    factors(N);
    factors(28);

    char buf[16];
    char *s;
    if ((s = itoa(buf, sizeof buf, 3104590)))
        printf("itoa: %s\n", s);
    else
        fprintf(stderr, "conversion error\n");

    return 0;
}
