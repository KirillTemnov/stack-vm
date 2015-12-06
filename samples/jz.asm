;; --------------------------------------------------------------------------------
;; jz/jnz example
;; --------------------------------------------------------------------------------
.data
        val     sw      10
.code
	load val
        push 10
        sub
        jz on_zero_flag
	stat
        halt
on_zero_flag:
        push 255
        stor val
	inc
        jnz not_a_zero
        stat
        halt

not_a_zero:
        load val
        push 3840
        add
        stor val                ; if all ok, we store #{0FFF}
        stat
        halt
