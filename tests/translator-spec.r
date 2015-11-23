REBOL [
    Title: "Translator tests"
    File: %translator-spec.r
    Author: "Kirill Temnov"
    Date: 15/11/2015
    ]


do %spec.r
do %../translator.r

t: make translator []

test/assert [equal? #{0000} t/int-to-word 0]
test/assert [equal? #{0001} t/int-to-word 1]
test/assert [equal? #{0080} t/int-to-word 128]
test/assert [equal? #{8000} t/int-to-word 32768]
test/assert [equal? #{FFFF} t/int-to-word 65535]
test/assert [equal? #{FFFF} t/int-to-word -1]
test/assert [equal? #{FF80} t/int-to-word -128]
test/assert [equal? #{8000} t/int-to-word -32768]

test/assert [equal? [["pop"]] t/source-to-block {pop}]
test/assert [equal? [["push" "0"]] t/source-to-block {push 0}]
test/assert [equal? [["push" "123"]] t/source-to-block {push 123}]
test/assert [equal? [["push" "456"]] t/source-to-block {push 456}]
test/assert [equal? [["push" "9874"]] t/source-to-block {push 9874}]
test/assert [equal? [["push" "32768"]] t/source-to-block {push 32768}]
test/assert [equal? [["add"]] t/source-to-block {add}]
test/assert [equal? [["sub"]] t/source-to-block {sub}]
test/assert [equal? [["and"]] t/source-to-block {and}]
test/assert [equal? [["or"]] t/source-to-block {or}]
test/assert [equal? [["xor"]] t/source-to-block {xor}]
test/assert [equal? [["inc"]] t/source-to-block {inc}]
test/assert [equal? [["dec"]] t/source-to-block {dec}]
test/assert [equal? [["drop"]] t/source-to-block {drop}]
test/assert [equal? [["dup"]] t/source-to-block {dup}]
test/assert [equal? [["over"]] t/source-to-block {over}]
test/assert [equal? [["swap"]] t/source-to-block {swap}]
test/assert [equal? [["stat"]] t/source-to-block {stat}]
test/assert [equal? [["halt"]] t/source-to-block {halt}]

test/assert [equal?
    [["push" "123"] ["push" "456"] ["add"]] t/source-to-block {
        push 123
        push 456
        add
    }
]

test/assert [equal? select opcodes "pop"  t/block-to-bytecode [["pop"]]]
test/assert [equal? select opcodes "add"  t/block-to-bytecode [["add"]]]
test/assert [equal? select opcodes "sub"  t/block-to-bytecode [["sub"]]]
test/assert [equal? select opcodes "and"  t/block-to-bytecode [["and"]]]
test/assert [equal? select opcodes "or"   t/block-to-bytecode [["or"]]]
test/assert [equal? select opcodes "xor"  t/block-to-bytecode [["xor"]]]
test/assert [equal? select opcodes "inc"  t/block-to-bytecode [["inc"]]]
test/assert [equal? select opcodes "dec"  t/block-to-bytecode [["dec"]]]
test/assert [equal? select opcodes "drop" t/block-to-bytecode [["drop"]]]
test/assert [equal? select opcodes "dup"  t/block-to-bytecode [["dup"]]]
test/assert [equal? select opcodes "over" t/block-to-bytecode [["over"]]]
test/assert [equal? select opcodes "swap" t/block-to-bytecode [["swap"]]]
test/assert [equal? select opcodes "stat" t/block-to-bytecode [["stat"]]]
test/assert [equal? select opcodes "halt" t/block-to-bytecode [["halt"]]]

test/assert [equal? join select opcodes "push" #{0001} t/block-to-bytecode [["push" "1"]]]
test/assert [equal? join select opcodes "push" #{007F} t/block-to-bytecode [["push" "127"]]]
test/assert [equal? join select opcodes "push" #{FFFF} t/block-to-bytecode [["push" "-1"]]]
test/assert [equal? join select opcodes "push" #{2692} t/block-to-bytecode [["push" "9874"]]]

;;  replace labels
test/assert [equal?
    [["push" "232"] ["call" 110] ["halt"]]
    t/replace-labels [["push" "232"] ["call" "RPC"] ["halt"]] to-hash ["RPC" 110]]

test/stat
