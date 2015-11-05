REBOL [
    Title: "Simple stack vitrual mashine"
    File: %vm.r
    Author: "Kirill Temnov"
    Date: 02/11/2015
    Version: 0.1.5
    ]


; vm commands:
;
;
;   command    | code
; nop          | 0x00
; push NUM     | 0x01
; add          | 0x02
; sub          | 0x03
; mul          | 0x04
; neg          | 0x05
; halt         | 0x99


; example

; source:  2 + 3
; ast: [add 2 3]
; push 2
; push 3
; add
; halt

vitrual-mashine: make object! [

    int-to-word: func [
        "Convert integer number to a word (binary!)"
        i [integer!]
    ][
        debase/base copy/part skip to-hex i 4 4 16
    ]

    word-to-int: func [
        "Convert binary word to integer"
        w [binary!]
        /local b1 b2
    ][
        b1: pick w 1
        b2: pick w 2
        ; shift first byte to the left on 8 bits
        b2 + shift/left b1 8
    ]

    swap-stack-values: func [
        "Swap two top level stack values"
        stack [block!]
        /local a b
    ][
        a: pick stack 1
        b: pick stack 2
        remove/part stack 2
        insert stack a
        insert stack b
        stack
    ]


    with-one-arg-do: func [
      ; Execute fn on top level stack value,
      ; push result on stack and return stack
        stack [block!]
        fn
    ] [
        val: fn (first stack)
        remove/part stack 1
        insert stack val
        stack
    ]

    with-two-args-do: func [
      ; Execute fn on two top level stack values,
      ; pop them from stack,
      ; push result on stack and return stack
        stack [block!]
        fn
    ] [
        val: fn (first stack)  (second stack)
        remove/part stack 2
        insert stack val
        stack
    ]

    stack: []
    code: #{}                           ; program code, loaded in vm
    registers: make object! [
        pc: 1                          ; program count
        cf: 0                          ; carry flag
        zf: 0                          ; zero flag
        ]


    get-word: func [
        "Get word (2 bytes) from binary"
        from
        index
        /local first-byte second-byte
    ][
        if error?
         try [
            first-byte: to-binary to-char pick from index
            index: index + 1
            second-byte: to-binary to-char pick from index
        ][
            print "Error fetching word"
            return #{0000}              ;
        ]
        join first-byte second-byte     ; big endian
    ]

    reset: func [
        "'Reboot' mashine"
    ] [
        print "reset mashine"
        clear stack
        registers/pc: 1
    ]

    dump-state: func [
        "Dump mashine status"
    ] [
        print ["STACK: " probe stack]
        print ["Regs: "  "PC: " registers/pc]
    ]

    ;; vm instructions
    inc: func [
        "Increment byte value"
        x [binary!]
    ] [
        int-to-word  1 + word-to-int x
    ]

    dec: func [
        "Decrement byte value"
        x [binary!]
    ] [
        int-to-word  -1 + word-to-int x
    ]

    add: func [
        "Add one operand to another"
        first-op [binary!]
        second-op [binary!]
        /local i1 i2
    ] [
        i1: word-to-int first-op
        i2: word-to-int second-op
        int-to-word i1 + i2
    ]

    sub: func [
        "Substract one operand from another"
        first-op  [binary!]
        second-op [binary!]
        /local i1 i2
    ] [
        i1: word-to-int first-op
        i2: word-to-int second-op
        int-to-word i1 - i2
    ]


    one-byte-instructions: #{00 02 03 04 05 06 07 08 09 0A 98 99} ;
    two-byte-instructions: #{01}                                  ;

    get-instruction-size: func [
        "Get size of instruction in bytes"
        instruction
    ][
        if none <> find two-byte-instructions instruction  [
            ; one byte - command, 2 bytes - data
            return 3
        ]
        if none <> find one-byte-instructions instruction  [return 1]
        return 1                        ; unknown instruction size: 1 byte
    ]

    apply-incstruction: func [
        {Apply single insruction.
         return true if instruction valid and not halt,
         otherwise, return false}       ;
        /local op size arg offset
    ] [
        if error?
         try [op: to-binary to-char pick code registers/pc]
        [
            print "Reach end of code block."
            return false
        ]
        size: get-instruction-size op
        arg: none
        if size > 1 [
            offset: registers/pc + 1
            arg: get-word code offset
            ]
        registers/pc: registers/pc + size
        switch/default op [
            ; nop
            #{00} []

            ; push
            #{01} [insert stack arg]

            ; add
            #{02}  [with-two-args-do stack :add]

            ; sub
            #{03}  [with-two-args-do stack :sub]

            ; mul
            ;#{04} [with-two-args-do stack :*]

            ; and
            #{05} [with-one-arg-do stack :and]

            ; or
            #{06} [with-two-args-do stack :or]

            ; xor
            #{07} [with-two-args-do stack :xor]

            ; inc
            #{08} [with-one-arg-do stack :inc]

            ; dec
            #{09} [with-one-arg-do stack :dec]

            ; pop/drop
            #{0A} [remove stack]

            ; dup
            #{0B} [insert stack pick stack 1]

            ; over
            #{0C} [insert stack pick stack 2]

            ; swap
            #{0D} [swap-stack-values stack]

            ; stat
            #{98} [dump-state]

            ; halt
            #{99} [
                dump-state
                return false
            ]
        ]
        [
            make error! rejoin ["COMMAND " op " NOT FOUND!"]
            return false
        ]
        return true

    ]

    run: func [
        "Execute program on virtual mashine"
        program
        /local last-result
    ] [
        code: program
        reset
        resume
    ]

    resume: func [
        "Resume execution from last point"
        ] [
        last-result: true
        while [last-result] [ last-result: apply-incstruction ]
        ]

]


vm: make vitrual-mashine []
