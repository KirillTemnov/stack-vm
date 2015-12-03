; --------------------------------------------------------------------------------
;;  this example handles call procedure
; --------------------------------------------------------------------------------
.data
   num1  sw  1
   num2  sw  5
   num3  sw  4

.code
main:
	load num1
	load num2
	load num3
        call make_sum_of_three
	stor num1
	stat
        halt                    ; int0 ?

make_sum_of_three:
        add
        add
        retn





;
;
