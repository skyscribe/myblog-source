#!/usr/bin/awk -f
BEGIN{
    for(i = 0; i < 10; i++){
        for(j = 0; j < 8; j++){
            grid[i, j] = i * j;
        }
    }
    grid[1,2,7] = 14;
    grid[4,2,7] = 56;

    if ( (1,2) in grid){
        printf("grid[1][2]=%d\n", grid[1,2]);
    }

    for(idx in grid){
        fmt = "grid[";
        n = split(idx, indices, SUBSEP);
        for (sub_idx = 1; sub_idx <= n; sub_idx++){
            fmt = fmt indices[sub_idx] "]["
        }
        printf("%s = %d\n", substr(fmt, 1, length(fmt) - 1), grid[idx])
    }
}

