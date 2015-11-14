REBOL [
    Title: "Translator for simple stack vitrual mashine"
    File: %translator.r
    Author: "Kirill Temnov"
    Date: 06/11/2015
    Version: 0.2.0
    ]

translator: context [
    spacer: charset " ^-^/"
    spaces: [some spacer]
    digit:  charset "012346789"
    one-byte-command:  [
       "pop"  | "add"  | "sub"  |
       "and"  | "or"   | "xor"  |
       "inc"  | "dec"  |
       "drop" | "dup"  | "over" | "swap" |
       "stat" | "halt"
    ]
    two-byte-command: ["push" some digit]

    list-of-commands: to-hash [
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
        "stat"    #{98}
        "halt"    #{99}
    ]


    int-to-word: func [
       {Convert integer number to a word (binary!)}
       i [integer!] "source (positive) integer"
    ][
       debase/base copy/part skip to-hex i 4 4 16
    ]


    source-to-block: func [
       {Translate source assembler code to a block! of commands}
       source [string! file!] "source code"
       /local lines result line-num
    ][
       lines: parse/all source "^/"
       result: copy []
       line-num: 1                   ; TODO add rule for comments
       foreach line lines [
          if (0 < length? trim line) [ ; skip empty lines
             unless parse line [
                [copy v one-byte-command end (insert result '_ result/1: join [] v)] |
                [copy v two-byte-command end (insert result '_ result/1: parse v "")]
                ][
                make error! reform ["error in line #" line-num ": " line]
             ]
          ]
          line-num: line-num + 1
       ]
       reverse result
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
