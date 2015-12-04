REBOL [
    Title: "Translator tests"
    File: %translator-spec.r
    Author: "Kirill Temnov"
    Date: 15/11/2015
    ]


do %spec.r
do %../translator.r

test: make test-suite [name: "Translator tests"]

opcodes: make opcodes-instance []
t: make translator []

; TODO replace fn call t/int-to-word
join-with-data: func [
    {Join code with data (data section goes first)}
    operator "Operator name"
    /arg     "argument"
    arg-val
    /data    "use not empty data"
    data-val
][
    arg-val: either arg [t/int-to-word arg-val] [#{}]
    data-val: either data [join t/int-to-word length? data-val data-val] [#{0000}]
    join data-val join select opcodes/opcodes operator arg-val
]


; int-to-word
test/assert [equal? #{0000} t/int-to-word 0]
test/assert [equal? #{0001} t/int-to-word 1]
test/assert [equal? #{0080} t/int-to-word 128]
test/assert [equal? #{8000} t/int-to-word 32768]
test/assert [equal? #{FFFF} t/int-to-word 65535]
test/assert [equal? #{FFFF} t/int-to-word -1]
test/assert [equal? #{FF80} t/int-to-word -128]
test/assert [equal? #{8000} t/int-to-word -32768]

;  substitute-labels-to-values
test/assert [equal?
    [["push" "232"] ["call" 110] ["halt"]]
    t/substitute-labels-to-values [["push" "232"] ["call" "RPC"] ["halt"]] to-hash ["RPC" 110] opcodes/label-commands]

test/assert [equal?
    [["load" 2] ["stor" 4]]
    t/substitute-labels-to-values [["load" "A"] ["stor" "B"]] to-hash ["A" 2 "B" 4] opcodes/data-manipulation-commands]


; generate-offsets-for-data
; helper hash
h-data: to-hash ["foo"]
append h-data make object! [val: #{01} skip: 0]
append h-data "bar"
append h-data make object! [val: #{020A} skip: 1]


test/assert [equal? to-hash ["foo" 0 "bar" 1] t/generate-offsets-for-data copy h-data]


; store-line MOVED INTO OTHER FN
; labels: copy []
; t/source-to-block/store-line labels 0 "my-label"

; store-var
sv-hash: t/store-var [] "fuu1      sw ^-125"
test/assert [
    and and
    equal? "fuu1" sv-hash/1
    equal? #{007D} sv-hash/2/val
    equal? 0 sv-hash/2/skip]

sv-hash: t/store-var sv-hash "bzzz_34A      sw -125"
test/assert [
    and and
    equal? "bzzz_34A" sv-hash/3
    equal? #{FF83} sv-hash/4/val
    equal? 2 sv-hash/4/skip]

; join-hash-data
test/assert [equal? #{01020A} t/join-hash-data copy h-data]

; source-to-block

; block-to-bytecode

test/assert [equal? join-with-data "pop"  t/block-to-bytecode [["pop"]]  #{}]
test/assert [equal? join-with-data "add"  t/block-to-bytecode [["add"]]  #{}]
test/assert [equal? join-with-data "sub"  t/block-to-bytecode [["sub"]]  #{}]
test/assert [equal? join-with-data "and"  t/block-to-bytecode [["and"]]  #{}]
test/assert [equal? join-with-data "or"   t/block-to-bytecode [["or"]]   #{}]
test/assert [equal? join-with-data "xor"  t/block-to-bytecode [["xor"]]  #{}]
test/assert [equal? join-with-data "inc"  t/block-to-bytecode [["inc"]]  #{}]
test/assert [equal? join-with-data "dec"  t/block-to-bytecode [["dec"]]  #{}]
test/assert [equal? join-with-data "drop" t/block-to-bytecode [["drop"]] #{}]
test/assert [equal? join-with-data "dup"  t/block-to-bytecode [["dup"]]  #{}]
test/assert [equal? join-with-data "over" t/block-to-bytecode [["over"]] #{}]
test/assert [equal? join-with-data "swap" t/block-to-bytecode [["swap"]] #{}]
test/assert [equal? join-with-data "stat" t/block-to-bytecode [["stat"]] #{}]
test/assert [equal? join-with-data "halt" t/block-to-bytecode [["halt"]] #{}]


test/assert [equal?
    join-with-data/arg/data "load" 1 #{000A}
    t/block-to-bytecode [["load" "1"]] #{000A}]

test/assert [equal?
    join-with-data/arg/data "stor" 127 #{C0C0}
    t/block-to-bytecode [["stor" "127"]] #{C0C0}]

test/assert [equal?
    join-with-data/arg/data "push" -1 #{8421}
    t/block-to-bytecode [["push" "-1"]] #{8421}]

test/assert [equal?
    join-with-data/arg/data "push" 9874 #{3AC3}
    t/block-to-bytecode [["push" "9874"]] #{3AC3}]



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









test/stat
