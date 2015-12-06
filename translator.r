#!/usr/bin/env rebol -cs

REBOL [
    Title: "Translator for simple stack vitrual mashine"
    File: %translator.r
    Author: "Kirill Temnov"
    Date: 06/11/2015
    ]


do %opcodes.r
do %utils.r

translator: context [
    debug: false

    opcodes: make opcodes-instance []
    utils: make utils-instance []


    one-byte-command: opcodes/generate-one-byte-rules
    three-byte-command: opcodes/generate-three-byte-rules
    var-definition: opcodes/generate-var-definition
    label-rule: opcodes/generate-label-rules

    list-of-commands: opcodes/opcodes



    substitute-labels-to-values: func [
        {Replace labels in `code` block mathed commands from `commands-list` to values
         from `label-value-hash`.
         This function places offset from begining of code or data in appropriate blocks
         (depends on `code` value)
        }
        code [block!]
        label-value-hash [hash!]
        commands-list [block!] "block of strings with command names"
        /local r cmd
    ][
        r: copy []
        foreach code-line code [
            cmd: first code-line
            either found? find commands-list cmd [
                append/only r join join [] cmd select label-value-hash second code-line
            ][
                append/only r join [] code-line
            ]
        ]
        r
    ]

    generate-offsets-for-data: func [
        {Generate offsets for data and merge }
        data-hash "hash with data and and object {val, skip}"
        /local r obj
    ][
        r: to-hash []
        forskip data-hash 2 [
            append r first data-hash
            obj: second data-hash
            append r obj/skip
        ]
        r
    ]


   store-var: func [
       {Store data label value and offset.
       Process only template:
       LABEL    SW  NUMBER.}

       container            "data container"
       data-string          "data string"
       /local splited label value len bytes-skip last-skip
   ][
       splited: parse/all data-string "sw"
       label: trim/all first splited
       value: utils/int-to-word to-integer trim/all last splited
       len: 2             ; for now length always 2 words
       bytes-skip: 0

       ; add hash key and value in separate lines
       if 0 < length? container [ bytes-skip: len + get in last container 'skip]

       append/only container label
       append/only container make object! [val: value skip: bytes-skip]
   ]


   join-hash-data: func [
       {Join data hash into raw binary.
         e.g. we have hash ["foo" make object! [val: #{01}] "bar" make object! [val: #{0203}]]
         and translate it to #{010203}.
       }

       hash-data "hash with data"
       /local result
   ][
     result: copy #{}
     forskip hash-data 2 [ append/only result get in second hash-data 'val]
     result
   ]


    run: func [
       {Translate source assembler code to a block! of commands}
       source [string! file!] "source code"
       /local
         lines
         code-blk
         data-blk
         labels
         mode
         line-num
         bytes
         trimmed-line
         code-wo-labels
         full-processed-code
         store-code
    ][
       lines: parse/all source "^/"
       code-blk: copy []
       data-blk: to-hash []
       labels: copy []
       mode: none               ; one of 'code 'data
       line-num: 1
       bytes: 1

       store-line: func [
           {Store line inside resulting block. Used by `source-to-block`.}
           container [block!] "container to store"
           cmd-len [integer!] "command length"
           cmd "command"
           ; bytes global for this func
       ][
           bytes: bytes + cmd-len
           cmd: trim/with cmd ":" ; remove last :
           switch/default cmd-len [
               0 [append container join join [] cmd bytes]

               1 [append/only container join [] cmd]

               3 [append/only container parse cmd none]

           ][
               make error! reform ["This is error. len:"  cmd-len "command:" cmd]
           ]
       ]

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
                              [copy v three-byte-command end (store-line code-blk 3 v)]
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

       code-wo-labels: substitute-labels-to-values code-blk to-hash labels opcodes/label-commands
       full-processed-code: substitute-labels-to-values code-wo-labels generate-offsets-for-data data-blk opcodes/data-manipulation-commands
       if debug [
           print ["code-wo-labels" probe code-wo-labels]
           print ["full-processed-code" probe full-processed-code]
       ]

       block-to-bytecode full-processed-code join-hash-data data-blk
    ]


    block-to-bytecode: func [
       {Translate commands and binary-data  to bytecode}

       commands [block!]
       binary-data
       /local code op
    ][
        code: copy #{}
        data: join utils/int-to-word length? binary-data binary-data
        foreach line commands [
            op: first line
            any [
              if found? find opcodes/one-byte-command-names op [
                 append code select list-of-commands op
              ]
              if found? find opcodes/three-byte-command-names op [
                  append code join select list-of-commands op utils/int-to-word to-integer second line
              ]
           ]
        ]
        join data code
     ]

 ]


; we have commands to translate
if system/options/args [
    print
    fname: first system/options/args
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
