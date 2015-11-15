#!/usr/bin/env rebol

REBOL [
    Title: "Tests suite for stack-vm"
    File: %tests.r
    Author: "Kirill Temnov"
    Date: 15/11/2015
    ]

cd %tests
returns: 0
foreach file load %. [
    unless equal? %spec.r file [
        returns: returns + do file
    ]
]

quit/return returns
