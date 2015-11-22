REBOL [
    Title: "Hash of opcodes and aux functions"
    File: %opcodes.r
    Author: "Kirill Temnov"
    Date: 22/11/2015
]

get-hash-keys: func [
    {Return block of keys, fetched from hash}
    hash
    /local keys
][
    keys: copy []
    forskip hash 2 [append keys first hash]
    keys
]

reverse-keys-and-vals: func [
    {Reverse key/value painrs and return new hash as result}
    hash
    /local i
][
    result: copy []
    forskip hash 2 [
        append result second hash
        append result first hash
    ]
    to-hash result
]

opcodes: to-hash [
    "pop"     #{00}
    "push"    #{01}
    "add"     #{02}
    "sub"     #{03}
    "and"     #{05}
    "or"      #{06}
    "xor"     #{07}
    "inc"     #{08}
    "dec"     #{09}
    "drop"    #{0A}
    "dup"     #{0B}
    "over"    #{0C}
    "swap"    #{0D}
    "stat"    #{98}
    "halt"    #{99}
]

opcode-names: reverse-keys-and-vals opcodes

two-byte-command-names: ["push"]
one-byte-command-names: difference get-hash-keys opcodes two-byte-command-names


insert-|: func [
    {Inserts | after each element of block}
    blk [block! string!]
][
    result: copy []
    foreach elem blk [
        append result elem
        append result '|
    ]
    take/last result
    result
]


generate-one-byte-rules: does [
    {Generate one byte command rules for parsing}
    insert-| one-byte-command-names
]

generate-two-byte-rules: does [
    {Generate one byte command rules for parsing}
    digit:  insert-| parse "0 1 2 3 4 5 6 7 8 9" " "
    ["push" some digit]
]


generate-byte-instructions: func [
    {Generate instructions set from opcodes and `command-names`}
    command-names
    /local result
][
    result: copy []
    foreach cmd command-names [
        append result select opcodes cmd
    ]
    rejoin result
]

generate-one-byte-instructions: does [generate-byte-instructions one-byte-command-names]

generate-two-byte-instructions: does [generate-byte-instructions two-byte-command-names]
