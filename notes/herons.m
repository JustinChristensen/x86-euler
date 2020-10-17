1;

function term0 = herons_term0(i)
    term0 = 200;
endfunction

function [sq, iters] = herons_cnt(i)
    prev = herons_term0(i);
    next = 0;
    iters = 0;

    while true
        iters++;
        next = floor((prev + ceil(i / prev)) / 2);
        if next == prev
            break;
        endif
        prev = next;
    endwhile

    sq = next;
endfunction

for i = 10000:99999
    [sq, iters] = herons_cnt(i);
    printf("%d %d %d\n", i, sq, iters);
endfor
