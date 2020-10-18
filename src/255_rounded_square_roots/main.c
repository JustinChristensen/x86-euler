#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

static inline unsigned long _floor(unsigned long a, unsigned long b) {
    return a / b;
}

static inline unsigned long _ceil(unsigned long a, unsigned long b) {
    return a / b + 1;
}

static unsigned long term0(unsigned long n) {
    (void) n;
    return 7000000;
    // return 200;
}

static inline unsigned long herons(int *iters, unsigned long n) {
    unsigned long next;
    int it = 0;

    for (unsigned long prev = term0(n);; prev = next) {
        it++;
//         if (n % 100000000 == 0) printf("%lu ", prev);
        next = _floor(prev + _ceil(n, prev), 2);
        if (next == prev) break;
    }

//     if (n % 100000000 == 0) printf("\n");

    *iters = it;

    return next;
}

static inline long total_iters(unsigned long s, unsigned long e) {
    long t = 0;

    while (s <= e) {
        int iters;
        unsigned long r = herons(&iters, s);

        if (s % 100000000 == 0)
            printf("herons(%lu) = %lu, %d iterations\n", s, r, iters);

        t += iters;
        s++;
    }

    return t;
}

#define NTHREADS 8

struct worker_args { long s, e; };

static void *average_iters_worker(void *_args) {
    struct worker_args args = *(struct worker_args *) _args;
    printf("thread created: %lu-%lu\n", args.s, args.e);
    return (void *) total_iters(args.s, args.e);
}

static void create_worker(pthread_t *tid, struct worker_args *args, unsigned long s, unsigned long e) {
    args->s = s; args->e = e;
    int err;
    if ((err = pthread_create(tid, NULL, average_iters_worker, args))) {
        fprintf(stderr, "thread creation error: %d\n", err);
        abort();
    }
}

static double parallel_average_iters(unsigned long s, unsigned long e) {
    struct worker_args argss[NTHREADS];
    pthread_t tids[NTHREADS];

    long slice = (e - s + 1) / 8;

    printf("%lu\n", slice);

    int i = 0;
    for (; i < NTHREADS - 1; i++) {
        unsigned long b = s + slice * i;
        create_worker(tids + i, argss + i, b, b + slice - 1);
    }

    unsigned long b = s + slice * i;
    create_worker(tids + i, argss + i, b, e);

    long t = 0;
    for (i = 0; i < NTHREADS; i++) {
        long wt;
        pthread_join(tids[i], (void **) &wt);
        t += wt;
    }

    return t / (double) (e - s + 1);
}

int main() {
    printf("average iterations: %lf\n", parallel_average_iters(10000000000000, 99999999999999));
    // printf("average iterations: %.10lf\n", parallel_average_iters(10000, 99999));
    return 0;
}

