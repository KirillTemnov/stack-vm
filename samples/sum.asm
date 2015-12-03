;; --------------------------------------------------------------------------------
;; this is a test assembler module for sum results
;; --------------------------------------------------------------------------------
.code
        push    123             ; first operand
        push    543             ; second operand
        stat
        add                     ; calculate sum
        stat
        halt
