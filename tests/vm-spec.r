REBOL [
    Title: "Tests of simple stack vitrual mashine"
    File: %vm-spec.r
    Author: "Kirill Temnov"
    Date: 03/11/2015
    ]

do %spec.r
do %../vm.r

vm: make vitrual-mashine []
test: make test-suite [name: "VM tests"]

; reset
use [test-vm] [
    test-vm: make vitrual-mashine [
        halt-flag: true
        data-stack: [#{FA00} #{0783}]
        memory: #{123456789009874321}
        return-stack: [#{0001} #{0002} #{0003}]
    ]
    test-vm/reset
    test/assert [
        and and and
        equal? false test-vm/halt-flag
        equal? [] test-vm/data-stack
        equal? #{} test-vm/memory
        equal? [] test-vm/return-stack
    ]
]

; inc
test/assert [equal? #{0002} vm/inc #{0001}]
test/assert [equal? #{FF10} vm/inc #{FF0F}]
test/assert [equal? #{0000} vm/inc #{FFFF}] ; carry flag

; dec
test/assert [equal? #{0000} vm/dec #{0001}]
test/assert [equal? #{FFFF} vm/dec #{0000}] ; carry flag
test/assert [equal? #{000F} vm/dec #{0010}]

; add
test/assert [equal? #{002F} vm/add #{000F} #{0020}]
test/assert [equal? #{0211} vm/add #{0111} #{0100}]
test/assert [equal? #{2221} vm/add #{9999} #{8888}] ; carry flag

; sub
test/assert [equal? #{8001} vm/sub #{8000} #{FFFF}] ; carry flag
test/assert [equal? #{0167} vm/sub #{0300} #{0199}]
test/assert [equal? #{FF1D} vm/sub #{0017} #{00FA}] ; carry flag

; load-to-stack
use [test-vm] [
    test-vm: make vitrual-mashine [memory: #{0011223344}]
    test-vm/load-to-stack #{0000}
    test/assert [equal? [#{0011}] test-vm/data-stack]
    test-vm/load-to-stack #{0003}
    test/assert [equal? [#{3344} #{0011}] test-vm/data-stack]
]

; stor-to-memory
use [test-vm] [
    test-vm: make vitrual-mashine [
        memory: #{0011223344}
        data-stack: [#{AABB} #{DDEF}]
    ]
    test-vm/stor-to-memory #{0000}
    test/assert [equal? #{AABB223344} test-vm/memory]
    remove test-vm/data-stack
    test-vm/stor-to-memory #{0001}
    test/assert [equal? #{AADDEF3344} test-vm/memory]
]

; call-proc
use [test-vm] [
    ; we don't have code here, so, we set `halt-flag` to prevent code cycling
    test-vm: make vitrual-mashine [halt-flag: true]
    test-vm/registers/pc: 70
    test-vm/call-proc #{0025}
    test/assert [
        and
        equal? [70] test-vm/return-stack
        equal?  37  test-vm/registers/pc
    ]

    test-vm/call-proc #{0010}
    test/assert [
        and
        equal? [70 37] test-vm/return-stack
        equal? 16 test-vm/registers/pc
    ]
]

; proc-return
use [test-vm] [
    ; we don't have code here, so, we set `halt-flag` to prevent code cycling
    test-vm: make vitrual-mashine [halt-flag: true]
    test-vm/return-stack: [12 25 50]
    test-vm/proc-return
    test/assert [equal? 50 test-vm/registers/pc]
    test-vm/proc-return
    test/assert [equal? 25 test-vm/registers/pc]
    test-vm/proc-return
    test/assert [equal? 12 test-vm/registers/pc]
]

; get-instruction-size / see instructions in opcodes
test/assert [equal? 3 vm/get-instruction-size #{02}]
test/assert [equal? 3 vm/get-instruction-size #{10}]
test/assert [equal? 3 vm/get-instruction-size #{0E}]
test/assert [equal? 3 vm/get-instruction-size #{0F}]
test/assert [equal? 1 vm/get-instruction-size #{00}]
test/assert [equal? 1 vm/get-instruction-size #{01}]
test/assert [equal? 1 vm/get-instruction-size #{03}]
test/assert [equal? 1 vm/get-instruction-size #{04}]
test/assert [equal? 1 vm/get-instruction-size #{05}]
test/assert [equal? 1 vm/get-instruction-size #{06}]
test/assert [equal? 1 vm/get-instruction-size #{07}]
test/assert [equal? 1 vm/get-instruction-size #{08}]
test/assert [equal? 1 vm/get-instruction-size #{09}]
test/assert [equal? 1 vm/get-instruction-size #{0A}]
test/assert [equal? 1 vm/get-instruction-size #{0B}]
test/assert [equal? 1 vm/get-instruction-size #{0C}]
test/assert [equal? 1 vm/get-instruction-size #{0D}]
test/assert [equal? 1 vm/get-instruction-size #{11}]
test/assert [equal? 1 vm/get-instruction-size #{98}]
test/assert [equal? 1 vm/get-instruction-size #{88}]

;; apply-instruction not tested here because of all its parst are tested in other unit tests.

; split-code-and-data
test/assert [equal? [#{} #{0200}] vm/split-code-and-data #{00000200}]
test/assert [equal? [#{AAAABBBB} #{0100}] vm/split-code-and-data #{0004AAAABBBB0100}]

;; run not tested here because of all its parst are tested in other unit tests.
; resume not tested here because of all its parst are tested in other unit tests.

test/stat
