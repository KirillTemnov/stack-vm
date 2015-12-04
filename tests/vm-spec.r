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



test/assert [equal? [#{} #{0200}] vm/split-code-and-data #{00000200}]
test/assert [equal? [#{AAAABBBB} #{0100}] vm/split-code-and-data #{0004AAAABBBB0100}]


; load-to-stack
vm/data-stack: []
vm/memory: #{0011223344}
vm/load-to-stack #{0000}
test/assert [equal? [#{0011}] vm/data-stack]
vm/load-to-stack #{0003}
test/assert [equal? [#{3344} #{0011}] vm/data-stack]


; stor to memory
vm/data-stack: [#{AABB} #{DDEF}]
vm/stor-to-memory #{0000}
test/assert [equal? #{AABB223344} vm/memory]
remove vm/data-stack
vm/stor-to-memory #{0001}
test/assert [equal? #{AADDEF3344} vm/memory]
vm/reset




; reset
; inc
; dec
; add
; sub
; get-instruction-size ??
;

test/stat
