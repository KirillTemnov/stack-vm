;; --------------------------------------------------------------------------------
;; This sample implements loop with jumps
;; --------------------------------------------------------------------------------
.data
        count     sw      0
        val       sw      0
.code
	push 10
loop_start:
        stor count
        drop
        load val
        push 5
        add
        stor val
        drop
        load count
        dec                     ; count was here!
        jnz  loop_start
        stat
        halt
