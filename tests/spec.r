REBOL [
    Title: "Testing library"
    File: %spec.r
    Author: "Kirill Temnov"
    Date: 15/11/2015
    ]

test-suite: context [
    total: ""
    errors: 0
    fails: 0

    assert: func [
        block
    ][
        if error?
        try [
            r: do block
            either do block [
                append total "."
                ][
                append total "F"
                print ["^/Fail on block" probe block]
                fails: fails + 1
             ]
          ][
          append total "E"
          errors: errors + 1
          print ["Error on block" block]
       ]

    ]

    stat: does [
        print ["^/" total "^/"]
        print ["Total test passed:" length? total ". Errors" errors ". Fails" fails]
        return fails
     ]
]

test: make test-suite []
