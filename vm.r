REBOL [
    Title: "Simple stack vitrual mashine"
    File: %vm.r
    Author: "Kirill Temnov"
    Date: 02/11/2015
    ]

do %opcodes.r
do %utils.r


vitrual-mashine: context [
    opcodes: make opcodes-instance []
    utils: make utils-instance []

    debug: false                ; debug flag
    halt-flag: false            ; halt flag, set and reset by vm functions

    data-stack: []
    return-stack: []
    memory: []                  ; program memory
    code: #{}                           ; program code, loaded in vm
    registers: make object! [
        pc: 1                          ; program count
        cf: 0                          ; carry flag
        zf: 0                          ; zero flag
        ]

    reset: does [ {Reset mashine state}
        if debug [print "reset mashine"]
        halt-flag: false
        clear data-stack
        clear memory
        registers/pc: 1
    ]

    dump-state: does [ {Dump mashine status}
        print ["DATA-STACK: "  data-stack]
        print ["MEMORY:"  memory]
        print ["Regs: "  "PC: " registers/pc]
    ]

    ;; ------------------------------------------------------------
    ;; vm instructions
    ;; ------------------------------------------------------------
    inc: func [
        {Increment byte value}
        x [binary!]
    ][
        utils/int-to-word  1 + utils/word-to-int x
    ]

    dec: func [
        {Decrement byte value}
        x [binary!]
    ][
        utils/int-to-word  -1 + utils/word-to-int x
    ]

    add: func [
        {Add one operand to another}
        first-op [binary!]
        second-op [binary!]
        /local i1 i2
    ][
        i1: utils/word-to-int first-op
        i2: utils/word-to-int second-op
        utils/int-to-word i1 + i2
    ]

    sub: func [
        {Substract one operand from another}
        first-op  [binary!]
        second-op [binary!]
        /local i1 i2
    ][
        i1: utils/word-to-int first-op
        i2: utils/word-to-int second-op
        utils/int-to-word i1 - i2
    ]


    load-to-stack: func [
        {Load word from memory on top of stack}
        offset [binary!] "offset from start of memory (zero-based)"
    ][
        ; offset points to 0 element which is 1 in rebol
        print ["LTS. memory:" memory "^/"]
        insert data-stack utils/get-word memory 1 + utils/word-to-int offset
    ]


    stor-to-memory: func [
        {Store value from top of stack to memory}
        offset [binary!] "offset from start of memory (zero-based)"
        /local w
    ][
       utils/put-word memory utils/word-to-int offset data-stack/1
    ]


    call-proc: func [           ; TODO reserve local stack for data
        {Call remote proc}
        addr "remote proc addr"
    ][
        append return-stack registers/pc
        registers/pc: utils/word-to-int addr
        resume
    ]

    proc-return: does [
        {Return from remote proc. Throws error if return stack is empty}
        registers/pc: take/last return-stack
        resume
    ]

    ; end of
    ; --------------------------------------------------------------------------------

    one-byte-instructions: opcodes/generate-one-byte-instructions
    three-byte-instructions: opcodes/generate-three-byte-instructions

    get-instruction-size: func [
        {Get size of instruction in bytes}
        instruction
    ][
        if none <> find three-byte-instructions instruction  [
            ; one byte - command, 2 bytes - data
            return 3
        ]
        ;if none <> find one-byte-instructions instruction  [return 1]
        return 1                        ; unknown instruction size: 1 byte
    ]

    apply-incstruction: func [
        {Apply single insruction.
         return true if instruction valid and not halt,
         otherwise, return false}       ;
        /local op size arg
    ][
        if error?
         try [op: to-binary to-char pick code registers/pc]
        [
            print "Reach end of code block."
            return false
        ]

        size: get-instruction-size op
        arg: none
        if size > 1 [
            arg: utils/get-word code (registers/pc + 1)
        ]
        if debug [
            print ["calling" select opcodes/opcode-names op "{" arg "}" "with size" size]
            print ["PC: " registers/pc "^/"]
        ]

        registers/pc: registers/pc + size
        switch/default select opcodes/opcode-names op [
            "nop" []

            "push" [insert data-stack arg]

            "add"  [utils/with-two-args-do data-stack :add]

            "sub"  [utils/with-two-args-do data-stack :sub]

            ; mul
            ;#{04} [with-two-args-do data-stack :*]

            "and" [utils/with-one-arg-do data-stack :and]

            "or" [utils/with-two-args-do data-stack :or]

            "xor" [utils/with-two-args-do data-stack :xor]

            "inc" [utils/with-one-arg-do data-stack :inc]

            "dec" [utils/with-one-arg-do data-stack :dec]

            "drop" [remove data-stack]

            "dup" [insert data-stack pick data-stack 1]

            "over" [insert data-stack pick data-stack 2]

            "swap" [utils/swap-stack-values data-stack]

            "call" [call-proc arg]

            "retn" [proc-return]

            "load" [load-to-stack arg]

            "stor" [stor-to-memory arg]

            "stat" [dump-state]

            "halt" [
                reset
                halt-flag: true
                return false
            ]
        ]
        [
            make error! rejoin ["COMMAND " op " NOT FOUND!"]
            return false
        ]
        return true

    ]

    split-code-and-data: func [
        {Split binary sequence into code and data
         first word in binary sequence is length of data section in BYTES (N),
         code data starts after N + 1 words and ends at end of sequence}

        data [binary!]
        /local size code script-data word-size
        ][
        word-size: 2            ; word size in bytes
        size: utils/word-to-int utils/get-word data 1
        code: copy/part skip data size + word-size length? data
        script-data: copy/part skip data word-size size
        do remold [script-data code]
    ]


    run: func [
        {Execute program in virtual mashine}
        program
        /local code-and-data
    ][
        reset
        code-and-data: split-code-and-data program
        memory: first code-and-data
        code: second code-and-data

        resume
    ]

    resume: does [{Resume execution from last point}
        unless halt-flag [
            last-result: true
            while [last-result and false = halt-flag] [
              last-result: apply-incstruction
          ]
        ]
        true
    ]

]
