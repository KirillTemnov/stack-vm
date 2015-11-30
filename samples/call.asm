; --------------------------------------------------------------------------------
;;  this example handles call procedure
; --------------------------------------------------------------------------------
.data
   num1  sw  1
   num2  sw  2
   num3  sw  4

.code
main:
	push 1
        push 2
        push 4
        call make_sum_of_three
	stat
        halt                    ; int0 ?

make_sum_of_three:
        add
        add
        retn





;
;
