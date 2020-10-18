.p2align 4

/*
Improvements to consider:
1. Use multiplicative inverse instead of division
2. Conditionally set the addend to 0 when neither i % 3 or i % 5 == 0 instead of jumping
*/

# eax `mod` edi
# eax - dividend
# edi - divisor
divides:
    xor %edx, %edx                # DIV divides edx:eax by src, so we've gotta zero edx
    div %edi
    test %edx, %edx
    ret

# eax = sum [i | i <- [3..1000], i `mod` 3 == 0 || i `mod` 5 == 0]
sum_multiples:
    xor %ebx, %ebx              # sum
    mov $3, %ecx
Lsum_multiples_loop:
    mov %ecx, %eax
    mov $3, %edi                # i % 3 == 0
    call divides
    je Lsum_multiples_loop_add
    # ||
    mov %ecx, %eax              # i % 5 == 0
    mov $5, %edi
    call divides
    je Lsum_multiples_loop_add

    jmp Lsum_multiples_loop_test
Lsum_multiples_loop_add:
    add %ecx, %ebx              # sum += i
Lsum_multiples_loop_test:
    inc %ecx                    # i++
    cmp $1000, %ecx
    jb Lsum_multiples_loop       # i <= 1000
    mov %ebx, %eax
    ret

.global start
start:
    call sum_multiples
    mov %eax, %esi
    call write_uint_nl
    call exit

