#!/usr/bin/env rebol

REBOL [
    Title: "Translator for simple stack vitrual mashine"
    File: %translator.r
    Author: "Kirill Temnov"
    Date: 06/11/2015
    Version: 0.2.0
    ]


do %opcodes.r

translator: context [

    one-byte-command: generate-one-byte-rules
    two-byte-command: generate-two-byte-rules
    label-rule: generate-label-rules

    list-of-commands: opcodes


    int-to-word: func [
       {Convert integer number to a word (binary!)}
       i [integer!] "source (positive) integer"
    ][
       debase/base copy/part skip to-hex i 4 4 16
    ]

    replace-labels: func [
        {Replace labels to numbers in blocks or code}
        code [block!]
        labels [hash!]
        /local r cmd
    ][
        r: copy []
        foreach code-line code [
            cmd: first code-line
            either found? find label-commands cmd [
                append/only r join join [] cmd select labels second code-line
            ][
                append/only r join [] code-line
            ]
        ]
        r
    ]


    source-to-block: func [
       {Translate source assembler code to a block! of commands}
       source [string! file!] "source code"
       /local lines result line-num trimmed-line store-line labels
    ][
       store-line: func [
           {Store line inside resulting block}
           container [block!] "container to store"
           cmd_len [integer!] "command length"
           cmd "command"
       ][
           bytes: bytes + cmd_len
           cmd: trim/with cmd ":" ; remove last :
           switch/default cmd_len [
               0 [append container join join [] cmd bytes]

               1 [append/only container join [] cmd]

               3 [append/only container parse cmd ""]

           ][
               print ["this is error. len:"  cmd_len "command:" cmd]
           ]
       ]

       lines: parse/all source "^/"
       result: copy []
       labels: copy []
       line-num: 1
       bytes: 1
       foreach line lines [
           trimmed-line: parse/all trim line ";" ; cut off comments part

           ; skip empty lines
           if (0 < length? trimmed-line) [ ; this is ugly part
              if (0 < length? first trimmed-line) [
                  trimmed-line: first trimmed-line
                  unless parse trimmed-line [
                      [copy v label-rule end (store-line labels 0 v)] |

                      [copy v one-byte-command end (store-line result 1 v)] |

                      [copy v two-byte-command end (store-line result 3 v)]
                  ][
                      make error! reform ["error in line #" line-num ": " line]
                  ]
               ]
           ]
           line-num: line-num + 1
       ]

       ; replace all labels to values in code
       replace-labels result to-hash labels
    ]


    block-to-bytecode: func [
       {Translate commands from block to bytecode}
       commands [block!]
       /local code op
    ][
        code: copy #{}
        data: copy #{}
        foreach line commands [
            op: first line
            any [
              if found? find one-byte-command-names op [
                 append code select list-of-commands op
              ]
              if found? find two-byte-command-names op [
                  append code join select list-of-commands op int-to-word to-integer second line
              ]
           ]
        ]
        join join [] code data
     ]


    run: func [
       {Translate source code to bytecode and pack it}
       source [string! file!]   ; read file and not process inside source to block?
       /local code-and-data code data
    ][

       code-and-data: block-to-bytecode source-to-block source

       code: first code-and-data
       data: second code-and-data
       join join int-to-word length? data data code
    ]


 ]

args: system/options/args

; we have commands to translate
if args [
    print
    fname: first args
    t: make translator []

    if error?
    try [
        file: read to-file fname
    ][
        print ["Error reading file" fname]
    ]

    if error?
    set/any 'err try [
        print t/run file
    ][
        print ["Translation error:"]
        print mold disarm get/any 'err
    ]
]
