REBOL [
    Title: "Translator tests"
    File: %translator-spec.r
    Author: "Kirill Temnov"
    Date: 15/11/2015
    ]


do %spec.r
do %../translator.r

test: make test-suite [name: "Translator tests"]

with-empty-data: func [
    operator
][
    join #{0000} select opcodes operator
]


t: make translator []

test/assert [equal? #{0000} t/int-to-word 0]
test/assert [equal? #{0001} t/int-to-word 1]
test/assert [equal? #{0080} t/int-to-word 128]
test/assert [equal? #{8000} t/int-to-word 32768]
test/assert [equal? #{FFFF} t/int-to-word 65535]
test/assert [equal? #{FFFF} t/int-to-word -1]
test/assert [equal? #{FF80} t/int-to-word -128]
test/assert [equal? #{8000} t/int-to-word -32768]


;; this is main run function in fact
;  it should be tested in parts
; test/assert [equal? [["pop"]] t/source-to-block {.code^/pop}]
; test/assert [equal? [["push" "0"]] t/source-to-block {.code^/push 0}]
; test/assert [equal? [["push" "123"]] t/source-to-block {.code^/push 123}]
; test/assert [equal? [["push" "456"]] t/source-to-block {.code^/push 456}]
; test/assert [equal? [["push" "9874"]] t/source-to-block {.code^/push 9874}]
; test/assert [equal? [["push" "32768"]] t/source-to-block {.code^/push 32768}]
; test/assert [equal? [["add"]] t/source-to-block {.code^/add}]
; test/assert [equal? [["sub"]] t/source-to-block {.code^/sub}]
; test/assert [equal? [["and"]] t/source-to-block {.code^/and}]
; test/assert [equal? [["or"]] t/source-to-block {.code^/or}]
; test/assert [equal? [["xor"]] t/source-to-block {.code^/xor}]
; test/assert [equal? [["inc"]] t/source-to-block {.code^/inc}]
; test/assert [equal? [["dec"]] t/source-to-block {.code^/dec}]
; test/assert [equal? [["drop"]] t/source-to-block {.code^/drop}]
; test/assert [equal? [["dup"]] t/source-to-block {.code^/dup}]
; test/assert [equal? [["over"]] t/source-to-block {.code^/over}]
; test/assert [equal? [["swap"]] t/source-to-block {.code^/swap}]
; test/assert [equal? [["stat"]] t/source-to-block {.code^/stat}]
; test/assert [equal? [["halt"]] t/source-to-block {.code^/halt}]

; test/assert [equal?
;     [["push" "123"] ["push" "456"] ["add"]]

;     t/source-to-block {
;         push 123
;         push 456
;         add
;     }
; ]

; test/assert [equal?
;     [["call" 4] ["push" "123"] ["push" "456"] ["add"]]

;     t/source-to-block {
;         call test
; test:
;         push 123
;         push 456
;         add

;     }
; ]

; test/assert [equal?
;     [["push" "1"] ["push" "2"] ["push" "3"] ["call" 14] ["stat"] ["add"] ["add"] ["retn"]]

;     t/source-to-block {
; main:
; 	push 1
;         push 2
;         push 3
;         call make_sum_of_three
; 	stat

; make_sum_of_three:
;         add
;         add
;         retn
;     }
; ]

; #{000001000101000201000310000E98020211}



test/assert [equal? with-empty-data "pop"  t/block-to-bytecode [["pop"]]  #{}]
test/assert [equal? with-empty-data "add"  t/block-to-bytecode [["add"]]  #{}]
test/assert [equal? with-empty-data "sub"  t/block-to-bytecode [["sub"]]  #{}]
test/assert [equal? with-empty-data "and"  t/block-to-bytecode [["and"]]  #{}]
test/assert [equal? with-empty-data "or"   t/block-to-bytecode [["or"]]   #{}]
test/assert [equal? with-empty-data "xor"  t/block-to-bytecode [["xor"]]  #{}]
test/assert [equal? with-empty-data "inc"  t/block-to-bytecode [["inc"]]  #{}]
test/assert [equal? with-empty-data "dec"  t/block-to-bytecode [["dec"]]  #{}]
test/assert [equal? with-empty-data "drop" t/block-to-bytecode [["drop"]] #{}]
test/assert [equal? with-empty-data "dup"  t/block-to-bytecode [["dup"]]  #{}]
test/assert [equal? with-empty-data "over" t/block-to-bytecode [["over"]] #{}]
test/assert [equal? with-empty-data "swap" t/block-to-bytecode [["swap"]] #{}]
test/assert [equal? with-empty-data "stat" t/block-to-bytecode [["stat"]] #{}]
test/assert [equal? with-empty-data "halt" t/block-to-bytecode [["halt"]] #{}]

; TODO enable this tests
; test/assert [equal?
;     with-empty-data/extra-data "push" #{0001}
;     t/block-to-bytecode [["push" "1"]]
; ]

; test/assert [equal?
;     with-empty-data/extra-data "push" #{007F}
;     t/block-to-bytecode [["push" "127"]]
; ]

; test/assert [equal?
;     with-empty-data/extra-data "push" #{FFFF}
;     t/block-to-bytecode [["push" "-1"]]
; ]

; test/assert [equal?
;     with-empty-data/extra-data "push" #{2692}
;     t/block-to-bytecode [["push" "9874"]]
; ]

;;  replace labels
test/assert [equal?
    [["push" "232"] ["call" 110] ["halt"]]
    t/replace-labels [["push" "232"] ["call" "RPC"] ["halt"]] to-hash ["RPC" 110]]

test/stat
