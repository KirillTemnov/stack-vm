REBOL [
    Title   : "Simple stack vitrual mashine"
    File    : %vm.r
    Author  : "Kirill Temnov"
    Date    : 02/11/2015
    Version : 0.0.1
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

    reset: func [
        ;; "reboot"  mashine
    ] [
        print "reset mashine"
        clear stack
    ]

    dump-state: func [
        ;; dump mashine status
    ] [
        prin "STACK: "
        print probe stack
    ]

    run: func [
        program
    ] [
        reset
        forall program [
            cmd: first program
            op: to binary! to char! cmd/1
            arg: cmd/2
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

                ; stat
                #{98} [dump-state]

                ; halt
                #{99} [return dump-state]
            ]
            [
            make error! rejoin ["COMMAND " op " NOT FOUND!"]
            return
            ]
        ]
    ]
]


vm: make vitrual-mashine []

vm/run [['oops]]

vm/run [
  #{01 02} ; push 2
  #{01 0C} ; push 12
  #{04}    ; mul
  #{00}    ; noop
  #{98}    ; stat
  #{00}    ; noop
]
