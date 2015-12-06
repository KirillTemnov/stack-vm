REBOL [
    Title: "Tests of simple stack vitrual mashine"
    File: %vm-spec.r
    Author: "Kirill Temnov"
    Date: 03/11/2015
    ]

do %spec.r
do %../utils.r

utils: make utils-instance []

test: make test-suite [name: "utils tests"]


test/assert [equal? #{0000} utils/int-to-word 0]
test/assert [equal? #{0001} utils/int-to-word 1]
test/assert [equal? #{0080} utils/int-to-word 128]
test/assert [equal? #{8000} utils/int-to-word 32768]
test/assert [equal? #{FFFF} utils/int-to-word 65535]
test/assert [equal? #{FFFF} utils/int-to-word -1]
test/assert [equal? #{FF80} utils/int-to-word -128]
test/assert [equal? #{8000} utils/int-to-word -32768]


test/assert [equal? 240 utils/word-to-int #{00F0}]
test/assert [equal? 292 utils/word-to-int #{0124}]
test/assert [equal? 31420 utils/word-to-int #{7ABC}]
test/assert [equal? 65440 utils/word-to-int #{FFA0}]


test/assert [equal? #{1122} utils/get-word #{00112233} 2]
test/assert [equal? #{2233} utils/get-word #{00112233} 3]

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

test/stat
