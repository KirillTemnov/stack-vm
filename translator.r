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
    digit:  ["0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"] ;charset "012346789"

    one-byte-command: generate-one-byte-rules
    two-byte-command: generate-two-byte-rules

    list-of-commands: opcodes


    int-to-word: func [
       {Convert integer number to a word (binary!)}
       i [integer!] "source (positive) integer"
    ][
       debase/base copy/part skip to-hex i 4 4 16
    ]


    source-to-block: func [
       {Translate source assembler code to a block! of commands}
       source [string! file!] "source code"
       /local lines result line-num trimmed-line
    ][
       lines: parse/all source "^/"
       result: copy []
       line-num: 1
       foreach line lines [
           trimmed-line: first parse/all trim line ";" ; cut off comments part
           if (0 < length? trimmed-line) [ ; skip empty lines
               unless parse trimmed-line [
                   [copy v one-byte-command end (append/only result join [] v)] |
                   [copy v two-byte-command end (append/only result parse v "")]
                   ][
                   make error! reform ["error in line #" line-num ": " line]
               ]
           ]
           line-num: line-num + 1
       ]
       result
    ]


    block-to-bytecode: func [
       {Translate commands from block to bytecode}
       commands [block!]
       /local code op
    ][
        code: copy #{}
        foreach line commands [
            op: first line
            any [
              if found? find one-byte-command op [
                 append code select list-of-commands op
              ]
              if found? find two-byte-command op [
                 append code join select list-of-commands op int-to-word to-integer second line
              ]
           ]
        ]
        code
     ]


    source-to-bytecode: func [
       {Translate source code to bytecode}
       source [string! file!]   ; read file and not process inside source to block?
    ][
       block-to-bytecode source-to-block source
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
        print t/source-to-bytecode file
    ][
        print ["Translation error:"]
        print mold disarm get/any 'err
    ]
]
