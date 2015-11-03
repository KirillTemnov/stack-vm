REBOL [
    Title: "Test of simple stack vitrual mashine"
    File: %vm-test.r
    Author: "Kirill Temnov"
    Date: 03/11/2015
    ]

do %vm.r

vm/run [
  #{01 02} ; push 2
  #{01 0C} ; push 12
  #{04}    ; mul
  #{00}    ; noop
  #{98}    ; stat
  #{00}    ; noop
]

print "and, or, inc, dec"
vm/run [
  #{01 0F}                              ; push 15
  #{01 04}                              ; push 4
  #{06}                                 ; and
  #{98}                                 ; dump state
  #{01 0A}                              ; push 10
  #{07}                                 ; or
  #{98}                                 ; stat
  #{08}                                 ; inc
  #{98}                                 ; stat
  #{09}                                 ; dec
  #{98}                                 ; stat
  #{0A}                                 ; pop
  #{98}                                 ; stat

]