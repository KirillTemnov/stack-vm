# Stack virtual mashine

Stack virtual mashine, that supports simple stacking operations, impolemented in Rebol 2.

## Running

For run vm, just clone repo. Rebol 2 must be installed and available in your OS.

```bash
git clone git@github.com:KirillTemnov/stack-vm.git
cd stack-vm
```

## Using

For execute code in virtual mashine, you can write code in assembler, or use one of [examples](samples).

For launching assembler code, firstly, you must tanslate it to a mashine code by passing filename to translator:

```bash
./translator.r samples/sum.asm
```

If no errors found, translator will put mashine code to console (like `#{000002007B02021F039899}` for `sum.asm` example).

Then, you may load this code into vm, by launching Rebol in root project folder and apply these instructions:

```rebol
do %vm.r
vm: make vitrual-mashine []
vm/run #{000002007B02021F039899}
```

You can inspect all vm variables after executiong a code. For more verbosity during run code process, set `debug` flag:

```rebol
vm: make vitrual-mashine [debug: true]
```

### Data types

For now, vm use only integer values, that fit in one word (#{FFFF}). Negative values **partially supported**.

### Quick guide on assembler

Each assembly file must contain `.code` section. Program execution started from first instruction after begining of `.code` section.

If you plan to store/load variables, provide `.data` section, before `.code`.
Each line of data section consist of label `sw` and decimal value. E.g.:

```asm
.data
  myVar         sw      10
  mySecondVar   sw      1024
```

Labels and function names consist of english alphanumeric chars and `_`. Must be started from any letter.

Empty lines and comments ignored by translator.
Comments strated from `;` and passed till the end of line.



### Assembler commands

| name  | explain |
|:-----:|:--------|
| `nop` | No operation. |
| `push` | Push variable to data-stack. |
| `add`  | Eval sum of first and second values in data-stack, remove them from data-stack and put result on top of it |
| `sub`  | Substract second value from first in data-stack, remove both variables from data-stack and put result on top of it |
| `and`  | Apply **and** operation on first and second values in data-stack, remove both from data-stack and put result on top of it |
| `or`   | Execute **or** operation. Works same as **and** |
| `xor`  | Execute **exclusive or** operation. Works same as **and** |
| `inc`  | Increment first value in data-stack |
| `dec`  | Deccrement first value in data-stack |
| `drop` | Extrat first value from data-stack. |
| `dup`  | Copy first value in data-stack and put it on top of data-stack |
| `over` | Copy second value in data-stack and put it on top of data-stack |
| `load` | Load variable (by name) from memory section on top of data-stack |
| `stor` | Store first value in data-stack into variable in memory |
| `call` | Call subroutine by name |
| `retn` | Return from subroutine |
| `stat` | Show vm status on console. Shows data-stack, memory and registers |
| `halt` | Halt mashine - end of a program |


## Testing

```bash
./run-tests
```

Don't tried to run tests on windows, please report on fails, if any.


## License

Released under the MIT license.
