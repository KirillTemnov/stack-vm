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
    debug: false

    one-byte-command: generate-one-byte-rules
    two-byte-command: generate-two-byte-rules
    var-definition: generate-var-definition
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
       /local lines code-blk data-blk line-num trimmed-line store-line labels
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


       store-var: func [
           {Store data label value and offset.
           Process only template:
           LABEL    SW  NUMBER}

           container            "data container"
           data-string          "data string"
           /local splited label value len bytes-skip last-skip
       ][
           splited: parse/all data-string "sw"
           label: trim/all first splited
           value: int-to-word to-integer trim/all last splited
           len: 2             ; for now length always 2 words


           ; add hash key and value in separate lines
           either 0 < length? container [
               last-skip: last container
               bytes-skip: len + last-skip/skip
           ][
               bytes-skip: 0
           ]
           append/only container label
           append/only container make object! [val: value skip: bytes-skip]
       ]

       join-hash-data: func [
           {Join data hash into raw binary}
           hash-data "hash with data"
           /local result entry
       ][
         result: copy #{}
         forskip hash-data 2 [
             entry: second hash-data
             append/only result entry/val
         ]
         result
       ]



       lines: parse/all source "^/"
       code-blk: copy []
       data-blk: to-hash []
       labels: copy []
       mode: none               ; one of 'code 'data
       line-num: 1
       bytes: 1
       foreach line lines [
           trimmed-line: parse/all trim line ";" ; cut off comments part

           ; skip empty lines
           if (0 < length? trimmed-line) [ ; this is ugly part
              if (0 < length? first trimmed-line) [
                  trimmed-line: first trimmed-line
                  if debug [
                      print ["L:" trimmed-line "{ " probe mode "}"]
                  ]
                  either 'code = mode [
                          parse trimmed-line [ ; todo add /all for parse
                              [copy v label-rule end (store-line labels 0 v)] |
                              [copy v one-byte-command end (store-line code-blk 1 v)] |
                              [copy v two-byte-command end (store-line code-blk 3 v)]
                          ][
                              make error! reform ["Error in code section. line #" line-num ": " line]
                          ]
                      ][
                          parse/all trimmed-line [
                              [copy v var-definition end (store-var data-blk v)] |

                              ; end of code section
                              [".code" (mode: 'code if debug [print ["in code mode"]])] |

                              ; end of data section
                              [".data" (mode: 'data if debug [print ["in data mode"]])]
                          ][
                              make error! reform ["Error in" mode "section. line #" line-num ": " line]
                          ]
                      ]


              ]
           ]
           line-num: line-num + 1
       ]

       ; TODO replace all labels to values in code
       ; print ["Data section: " probe data-blk]
       ;
       block-to-bytecode replace-labels code-blk to-hash labels join-hash-data data-blk
    ]


    block-to-bytecode: func [
       {Translate commands and binary-data  to bytecode}

       commands [block!]
       binary-data
       /local code op
    ][
        code: copy #{}
        data: join int-to-word length? binary-data binary-data
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
        join data code
     ]


    run: func [
       {Translate source code to bytecode and pack it}
       source [string! file!]   ; read file and not process inside source to block?
       /local code-and-data code data
    ][
       source-to-block source
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
