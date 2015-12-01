REBOL [
    Title: "Tests of simple stack vitrual mashine"
    File: %vm-spec.r
    Author: "Kirill Temnov"
    Date: 03/11/2015
    ]

do %spec.r
do %../vm.r

vm: make vitrual-mashine []

test: make test-suite [name: "VM tests"]



test/assert [equal? [#{} #{0200}] vm/split-code-and-data #{00000200}]
test/assert [equal? [#{AAAABBBB} #{0100}] vm/split-code-and-data #{0004AAAABBBB0100}]

test/assert [equal? #{0000} vm/int-to-word 0]
test/assert [equal? #{0001} vm/int-to-word 1]
test/assert [equal? #{0164} vm/int-to-word 356]
test/assert [equal? #{8000} vm/int-to-word 32768]
test/assert [equal? #{FF83} vm/int-to-word -125]

test/assert [equal? 240 vm/word-to-int #{00F0}]
test/assert [equal? 292 vm/word-to-int #{0124}]
test/assert [equal? 31420 vm/word-to-int #{7ABC}]
test/assert [equal? 65440 vm/word-to-int #{FFA0}]


test/assert [equal? #{1122} vm/get-word #{00112233} 2]
test/assert [equal? #{2233} vm/get-word #{00112233} 3]

; TODO
; this part not work, strange ...
; test/assert [equal? [f d] vm/swap-stack-values [d f]]
; test/assert [equal? [b a] vm/swap-stack-values [a b]]
; test/assert [equal? [1 0] vm/swap-stack-values [0 1]]
; test/assert [equal? [bar foo buzz] vm/swap-stack-values [foo bar buzz]]
; test/assert [equal? [none none] vm/swap-stack-values []]
; test/assert [equal? [none fuzz] vm/swap-stack-values [fuzz]]

; test/assert [equal? [2] vm/with-one-arg-do [1] func [z] [z + 1]]
; test/assert [equal? [-44] vm/with-one-arg-do [1] func [z] [z - 45]]

; test/assert [equal? [15] vm/with-two-args-do [7 8] func [a b] [a + b]]
; test/assert [equal? [455] vm/with-two-args-do [35 13] func [a ] [a * b]]


; reset
; inc
; dec
; add
; sub
; get-instruction-size ??
;

test/stat
