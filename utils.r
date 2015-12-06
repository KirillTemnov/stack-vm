
REBOL [
    Title: "Helper functions"
    File: %utils.r
    Author: "Kirill Temnov"
    Date: 04/12/2015
    ]

utils-instance: context [
    int-to-word: func [
       {Convert integer number to a word (binary!)}
       i [integer!] "source (positive) integer"
    ][
       debase/base copy/part skip to-hex i 4 4 16
    ]

    word-to-int: func [
        {Convert binary word to integer}
        w [binary!]
        /local b1 b2
    ][
        b1: pick w 1
        b2: pick w 2
        ; shift first byte to the left on 8 bits
        b2 + shift/left b1 8
    ]

    swap-stack-values: func [
        {Swap two top level stack values}
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
       { Execute fn on top level stack value,
         push result on stack and return stack}
        stack [block!]
        fn
    ][
        val: fn (first stack)
        remove/part stack 1
        insert stack val
        stack
    ]


    with-two-args-do: func [
      { Execute fn on two top level stack values,
        pop them from stack,
        push result on stack and return stack}
        stack [block!]
        fn
    ][
        val: fn (first stack)  (second stack)
        remove/part stack 2
        insert stack val
        stack
    ]


    get-word: func [
        {Get word (2 bytes) located by `index` from `data-raw`}
        data-raw
        offset
        /local first-byte second-byte
    ][
        if error?
         try [
            first-byte: to-binary to-char pick data-raw offset
            second-byte: to-binary to-char pick data-raw offset + 1
        ][
            print "Error fetching word"
            return #{0000}              ;
        ]
        join first-byte second-byte     ; big endian
    ]

    put-word: func [
        {Put word (2 bytes) into `data-raw` with `offset`.}
        data-raw
        offset
        word
        /local first-byte second-byte
    ][
        first-byte: to-binary to-char word/1
        second-byte: to-binary to-char word/2
        change skip data-raw offset first-byte
        change skip data-raw offset + 1 second-byte
    ]

]
