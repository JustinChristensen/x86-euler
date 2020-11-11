#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <zlib.h>

enum chunk_type {
    IHDR = 0x52444849,
    IDAT = 0x54414449,
    IEND = 0x444e4549
};

struct chunk_header {
    uint32_t length;
    enum chunk_type type;
};

#define LEN(chunk) ntohl((chunk)->length)

static struct chunk_header *next_chunk(struct chunk_header *curr) {
    char *buf = (char *) (curr + 1);
    buf += LEN(curr) + 4;        // crc
    return (struct chunk_header *) buf;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "no input file\n");
        return 1;
    }

    char *file = argv[1];
    FILE *in = fopen(file, "r");
    if (!in) {
        fprintf(stderr, "failed to open %s\n", file);
        perror(NULL);
        return 1;
    }

    struct stat stats;
    if (fstat(fileno(in), &stats) == -1) {
        perror(NULL);
        fclose(in);
        return 1;
    }

    size_t n = stats.st_size;
    char *png = malloc(n);
    if (!png) {
        perror(NULL);
        fclose(in);
        return 1;
    }

    size_t nread;
    if ((nread = fread(png, 1, n, in)) < n) {
        perror(NULL);
        free(png);
        fclose(in);
        return 1;
    }

    uint64_t sig = *(uint64_t *) png;
    struct chunk_header *c = (struct chunk_header *) (png + sizeof sig);
    if (sig != 0x0a1a0a0d474e5089) {
        fprintf(stderr, "%s is not a png\n", file);
        free(png);
        fclose(in);
        return 1;
    }

    printf("%s is a png\n", file);

    while (c->type != IEND) {
        printf("%.4s\n", (char *) &c->type);
        c = next_chunk(c);
    }

    printf("%.4s\n", (char *) &c->type);

    free(png);
    fclose(in);

    return 0;
}
