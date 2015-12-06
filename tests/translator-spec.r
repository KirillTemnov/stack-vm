REBOL [
    Title: "Translator tests"
    File: %translator-spec.r
    Author: "Kirill Temnov"
    Date: 15/11/2015
    ]


do %spec.r
do %../translator.r
do %../utils.r

utils: make utils-instance []

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
    arg-val: either arg [utils/int-to-word arg-val] [#{}]
    data-val: either data [join utils/int-to-word length? data-val data-val] [#{0000}]
    join data-val join select opcodes/opcodes operator arg-val
]



;  substitute-labels-to-values
test/assert [equal?
    [["push" "232"] ["call" 110] ["halt"]]
    t/substitute-labels-to-values [["push" "232"] ["call" "RPC"] ["halt"]] to-hash ["RPC" 110] opcodes/label-commands]

test/assert [equal?
    [["load" 2] ["stor" 4]]
    t/substitute-labels-to-values [["load" "A"] ["stor" "B"]] to-hash ["A" 2 "B" 4] opcodes/data-manipulation-commands]

test/assert [equal?
    [["jmp" 10] ["jz" 17] ["jnz" 6]]
    t/substitute-labels-to-values [["jmp" "JJ"] ["jz" "JUMP_ON_ZERO"] ["jnz" "jmp_not_0"]] to-hash ["JJ" 10 "JUMP_ON_ZERO" 17 "jmp_not_0" 6] opcodes/label-commands]


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

; block-to-bytecode
test/assert [equal? join-with-data "nop"  t/block-to-bytecode [["nop"]]  #{}]
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
test/assert [equal? join-with-data "retn" t/block-to-bytecode [["retn"]] #{}]


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


; source-to-block
; get samples and test is
use [src prog] [
    prog: #{000002007B02021F039899}
    src: {
     .code
        push    123             ; first operand
        push    543             ; second operand
        add                     ; calculate sum
        stat
        halt
    }

    test/assert [equal? prog t/run src]

    prog: #{00060001000500040E00000E00020E00041000120F00009899030311}
    src: {
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
              halt

      make_sum_of_three:
              add
              add
              retn
    }

    test/assert [equal? prog t/run src]
]


test/stat
