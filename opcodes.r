REBOL [
    Title: "Hash of opcodes and aux functions"
    File: %opcodes.r
    Author: "Kirill Temnov"
    Date: 22/11/2015
]


opcodes-instance: context [
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
        "load"    #{0E}
        "stor"    #{0F}
        "call"    #{10}
        "retn"    #{11}
        "stat"    #{98}
        "halt"    #{99}
    ]

    opcode-names: reverse-keys-and-vals opcodes

    three-byte-command-names: ["push" "call" "load" "stor"]
    one-byte-command-names: difference get-hash-keys opcodes three-byte-command-names
    label-commands: ["call"]        ; todo jump etc


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

    generate-three-byte-rules: does [
        {Generate three byte command rules for parsing}
        digit:  insert-| parse "0 1 2 3 4 5 6 7 8 9" " "
        letter: charset [#"a" - #"z" #"A" - #"Z" "_" #"0" - #"9"]
        label: [some letter ":"]
        [["push" some digit] | ["call" some letter]]
    ]

    generate-label-rules: does [
        {Generate label rules}
        letter: charset [#"a" - #"z" #"A" - #"Z" "_" #"0" - #"9"]
        [some letter ":"]
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

    generate-three-byte-instructions: does [generate-byte-instructions three-byte-command-names]


    generate-var-definition: does [
        {Generate definition for variable}
        letter: charset [#"a" - #"z" #"A" - #"Z" "_" #"0" - #"9"]
        digit:  charset [#"0" - #"9"]
        ws-char: charset [" " "^t" "^/"]
        ws: [some ws-char]
        sign: ["-" | "+" | ]
        num: [sign some digit]
        [some letter ws "sw" ws num] ; sw = single word
    ]
]
