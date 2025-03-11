# Lexa programming language

## Lexa [ˈlʲɵxə] - pronounced as l'yoha
- the "Л" is pronounced like the "L" sound in "love" but with a slightly palatalized or softened quality
- the "ё" sounds like the "yo" in "yoga"
- the "х" is a voiceless velar fricative, similar to the "ch" in the german "Bach"
- the "а" is pronounced as the "a" in "sofa," a schwa sound

a custom programming language with a unique syntax, implemented to run inside roblox
this language includes a lexer, parser, and an interpreter

## installation guide

follow these steps to add Lexa to ur game:

1. **create folders**
   - create a folder called `Лёха` in `ServerScriptService`
   - create a folder called `examples` in `ReplicatedStorage`

2. **create core modules**
   - inside `ServerScriptService/Лёха`, create these modulescripts:
     - `lexer`: tokenizes the code
     - `parser`: converts tokens to an AST
     - `interpreter`: executes the AST
     - `main`: main entry point for the language

3. **add example programs**
   - inside `ReplicatedStorage/LexaExamples`, add these modulescripts:
     - `hello_world.lexa`
     - `fibonnaci.lexa`
     - `multiplication_table.lexa`

## syntax

### program structure

every Lexa program begins with the keyword `здарова` followed by the filename (which has a `.lexa` extension) and ends with the phrase `давай бб`

```
здарова helloworld.lexa
//// code here
давай бб
```

### statements and \<eof\>

each statement in Lexa ends with the keyword `стоять` (similar to a semicolon in other languages)

```
ебаника "zdarova Lexa" стоять
//// lua equivalent: print("zdarova Lexa");
```

### keywords and their meanings

| keyword         | meaning                     | example                                        |
|-----------------|-----------------------------|------------------------------------------------|
| `здарова`       | program start               | `здарова myprogram.lexa`                       |
| `давай бб`      | program end                 | `давай бб`                                     |
| `стоять`        | statement terminator        | `ебаника "Hello" стоять`                       |
| `ебаника`       | print statement             | `ебаника "Hello, World!" стоять`               |
| `хуйняебаная`   | function definition         | `хуйняебаная square(x)`                        |
| `если`          | if statement                | `если x > 0 тогда`                             |
| `тогда`         | then (follows if)           | `если x > 0 тогда`                             |
| `уёбывай`       | return statement            | `уёбывай x * x стоять`                         |
| `похуй`         | end block                   | `если x > 0 тогда ... похуй стоять`            |
| `для_каждого`   | for loop                    | `для_каждого i = 1, 10 ебашьследующее`         |
| `ебашьследующее`| loop iteration              | `для_каждого i = 1, 10 ебашьследующее`         |
| `нарик`         | variable declaration        | `нарик x = 10 стоять`                          |

### comments

- single-line comments begin with `////`
- multi-line comments start with `////!!!` and end with `!!!////`

```
//// this is a single-line comment

////!!! this is a
multi-line
comment !!!////
```

## example programs

### hello world

```
здарова helloworld.lexa
ебаника "Hello, World!" стоять
давай бб
```

### fibonacci function

```
здарова fibonacci.lexa
хуйняебаная фиб(н)
    если н <= 0 тогда уёбывай 0 похуй стоять
    если н == 1 тогда уёбывай 1 похуй стоять
    уёбывай фиб(н-1) + фиб(н-2) стоять
похуй стоять

для_каждого и = 0, 10 ебашьследующее
    ебаника "Fib(" .. и .. ") = " .. фиб(и) стоять
похуй стоять
давай бб
```

### multiplication table

```
здарова multiplicationtable.lexa
для_каждого и = 1, 5 ебашьследующее
    нарик линия = "" стоять
    для_каждого д = 1, 5 ебашьследующее
        линия = линия .. (и * д) .. "\t" стоять
    похуй стоять
    ебаника линия стоять
похуй стоять
давай бб
```

## using Lexa in ur game

### running Lexa code from a script

```lua
local LexaMain = require(game.ServerScriptService["Лёха"].main)

local lexaCode = [[
здарова myprogram.lexa
ебаника "Hello from Lexa!" стоять
давай бб
]]

local output = LexaMain.run(lexaCode)
print(output)
```

### using the UI examples

there's an example `.rbxl` place in this folder
download it and check it out urself

## technical implementation

the Lexa language implementation consists of:

1. **lexer**: breaks down source code into tokens, handling keywords, identifiers, strings, numbers, operators, and comments
2. **parser**: builds an Abstract Syntax Tree (AST) representing the program structure
3. **interpreter**: executes the AST with a bytecode-based VM, including a stack for values, constants pool, and call frames for functions

## notes

- the implementation is designed to work within roblox
- all printing is done through Roblox's `print()` function and captured for UI display
- the UI allows u to experiment with the language without modifying scripts
- u can extend the language by modifying the modules in `ServerScriptService/Лёха`
