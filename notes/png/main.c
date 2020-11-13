#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <zlib.h>

enum chunk_type {
    IHDR = 0x52444849,
    zTXt = 0x7458547a,
    iCCP = 0x50434369,
    pHYs = 0x73594870,
    tIME = 0x454d4974,
    IDAT = 0x54414449,
    IEND = 0x444e4549
};

union chunk_data {
    void *data;
    struct {
        uint32_t width;
        uint32_t height;
        uint8_t bit_depth;
        uint8_t color_type;
        uint8_t compression_method;
        uint8_t filter_method;
        uint8_t interlace_method;
    };
};

struct chunk {
    uint32_t length;
    enum chunk_type type;
    unsigned char *data;
    uint32_t crc;
    unsigned char *next;
};

static struct chunk as_chunk(unsigned char *png) {
    struct chunk c;

    c.length = ntohl(*(uint32_t *) png);
    c.type = *(enum chunk_type *) (png += 4);
    c.data = (png += 4);
    c.crc = ntohl(*(uint32_t *) (png += c.length));
    c.next = png + 4;

    return c;
}

static union chunk_data chunk_data(struct chunk *chunk) {
    union chunk_data data;

    unsigned char *d = chunk->data;

    switch (chunk->type) {
        case IHDR:
            data.width = ntohl(*(uint32_t *) d), d += 4;
            data.height = ntohl(*(uint32_t *) d), d += 4;
            data.bit_depth = *d++;
            data.color_type = *d++;
            data.compression_method = *d++;
            data.filter_method = *d++;
            data.interlace_method = *d++;
            break;
        default:
            data.data = d;
            break;
    }

    return data;
}

void print_chunk_data(FILE *handle, enum chunk_type type, union chunk_data *data) {
    switch (type) {
        case IHDR:
            fprintf(handle, "  width: %u\n  height: %u\n  bit_depth: %hhu\n  color_type: %hhu\n"
                   "  compression_method: %hhu\n  filter_method: %hhu\n  interlace_method: %hhu\n",
                   data->width, data->height, data->bit_depth, data->color_type,
                   data->compression_method, data->filter_method, data->interlace_method);
            break;
        default:
            break;
    }
}

static void next_chunk(struct chunk *chunk) {
    *chunk = as_chunk(chunk->next);
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

    // file buffer
    size_t n = stats.st_size;
    unsigned char *png = malloc(n);
    if (!png) {
        perror(NULL);
        fclose(in);
        return 1;
    }

    // scratch space
    unsigned char *buf = malloc(n);
    if (!buf) {
        perror(NULL);
        free(png);
        fclose(in);
        return 1;
    }


    size_t nread;
    if ((nread = fread(png, 1, n, in)) < n) {
        perror(NULL);
        free(png), free(buf);
        fclose(in);
        return 1;
    }

    uint64_t sig = *(uint64_t *) png;
    struct chunk c = as_chunk(png + sizeof sig);
    if (sig != 0x0a1a0a0d474e5089) {
        fprintf(stderr, "%s is not a png\n", file);
        free(png), free(buf);
        fclose(in);
        return 1;
    }

    printf("%s is a png\n", file);

    z_stream strm = { 0 };
    inflateInit(&strm);

    while (c.type != IEND) {
        printf("%.4s %d\n", (char *) &c.type, c.length);

        if (c.type == IHDR) {
            union chunk_data data = chunk_data(&c);
            print_chunk_data(stdout, c.type, &data);
        } else if (c.type == IDAT) {
            strm.next_in = c.data;
            strm.avail_in = c.length;
            strm.next_out = buf;
            strm.avail_out = n;

            int ret;
            if ((ret = inflate(&strm, Z_NO_FLUSH)) == Z_DATA_ERROR) {
                printf("ret: %d, msg: %s\n", ret, strm.msg);
                break;
            } else {
                printf("ret: %d, inflated %lu bytes\n", ret, strm.total_out);

                for (int i = 0; i < 12; i++) {
                    for (int j = i * 32; j < (i + 1) * 32; j++) printf("%.2x ", buf[j]);
                    printf("\n");
                }
            }
        }

        next_chunk(&c);
    }

    free(png), free(buf);
    fclose(in);

    return 0;
}
