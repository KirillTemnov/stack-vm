REBOL [
    Title: "Tests of simple stack vitrual mashine"
    File: %vm-spec.r
    Author: "Kirill Temnov"
    Date: 03/11/2015
    ]

do %spec.r
do %../vm.r

vm: make vitrual-mashine []



test/assert [equal? [#{} #{0200}] vm/split-code-and-data #{00000200}]
test/assert [equal? [#{AAAABBBB} #{0100}] vm/split-code-and-data #{0002AAAABBBB0100}]

; TODO
; int-to-word
; word-to-int
; swap-stack-values
; with-one-arg-do
; with-two-args-do
; get-word
; reset
; inc
; dec
; add
; sub
; get-instruction-size ??
;

test/stat
