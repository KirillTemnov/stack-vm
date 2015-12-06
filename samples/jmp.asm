;; --------------------------------------------------------------------------------
;; jmp example
;; --------------------------------------------------------------------------------
.data
        val     sw      5
.code
	jmp skip
	load val
        push 5
        add
        stor val

skip:
	load val
        push 16
        add
        stor val
        stat
        halt
