#include <stdio.h>
#include <stdlib.h>

void even_fibs() {
    unsigned i = 1, j = 2, sum = 0;

    do {
        if (!(j & 1)) sum += j;
        unsigned k = i + j;
        i = j;
        j = k;
    } while (j <= 4000000);

    printf("%u\n", sum);
}

int main() {
    even_fibs();
    return 0;
}
