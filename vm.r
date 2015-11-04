REBOL [
    Title: "Simple stack vitrual mashine"
    File: %vm.r
    Author: "Kirill Temnov"
    Date: 02/11/2015
    Version: 0.1.0
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
    with-one-arg-do: func [
      ; Execute fn on top level stack value,
      ; push result on stack and return stack
        stack [block!]
        fn
    ] [
        val: fn (first stack)
        remove/part stack 1
        insert stack val
        return stack
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
        return stack
    ]

    stack: []
    code: #{}                           ; program code, loaded in vm
    registers: make object! [
        pc: 1                          ; program count
        ]


    reset: func [
        { "reboot"  mashine }           ;
    ] [
        print "reset mashine"
        clear stack
        registers/pc: 1
    ]

    dump-state: func [
        ;; dump mashine status
    ] [
        print ["STACK: " probe stack]
        print ["Regs: "  "PC: " registers/pc]
    ]

    inc: func [x] [x + 1]
    dec: func [x] [x - 1]

    one-byte-instructions: #{00 02 03 04 05 06 07 08 09 0A 98 99} ;
    two-byte-instructions: #{01}                                  ;

    get-instruction-size: func [
        "Get size of instruction in bytes"
        instruction
    ][
        if none <> find two-byte-instructions instruction  [return 2]
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
         try [op: to binary! to char! pick code registers/pc]
        [
            print "Reach end of code block."
            return false
        ]
        size: get-instruction-size op
        arg: none
        if size > 1 [
            offset: registers/pc + 1
            arg: pick code offset       ; todo transform to byte
            ]
        registers/pc: registers/pc + size
        switch/default op [
            ; nop
            #{00} []

            ; push
            #{01} [insert stack arg]

            ; add
            #{02}  [with-two-args-do stack :+]

            ; sub
            #{03}  [with-two-args-do stack :-]

            ; mul
            #{04} [with-two-args-do stack :*]

            ; neg
            #{05} [with-one-arg-do stack :negate]

            ; and
            #{06} [with-two-args-do stack :and]

            ; or
            #{07} [with-two-args-do stack :or]

            ; inc
            #{08} [with-one-arg-do stack :inc]

            ; dec
            #{09} [with-one-arg-do stack :dec]

            ; pop
            #{0A} [stack: next stack]

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
