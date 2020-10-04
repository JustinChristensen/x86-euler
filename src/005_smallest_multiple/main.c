#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>

int main() {
    uint8_t powers[21] = {
        [2] = 1, [3] = 1, [5] = 1, [7] = 1,
        [11] = 1, [13] = 1, [17] = 1, [19] = 1
    };

    int iters = 0;
    for (int i = 2; i <= 20; i++) {
        for (int n = i, j = 2; n && j <= 20; j++) {
            if (!powers[j]) continue;
            int p = 0;

            while (n % j == 0) {
                n /= j;
                p++;
                iters++;
            }

            powers[j] = p > powers[j] ? p : powers[j];
        }
    }

    for (int i = 2; i <= 20; i++) printf("%2d ", i); printf("\n");
    for (int i = 2; i <= 20; i++) printf("%2d ", powers[i]); printf("\n");

    int n = 1;
    for (int i = 2; i <= 20; i++) {
        if (!powers[i]) continue;
        int p = powers[i];
        while (p--) n *= i;
    }

    printf("%d iterations\n", iters);
    printf("%d\n", n);

    return 0;
}

