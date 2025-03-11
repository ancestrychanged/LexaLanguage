-- ServerScriptService/Лёха/main.lua

--[[
главный модуль для языка программирования Леха
это основная точка входа для интерпретатора языка Леха
модуль объединяет лексер, парсер и интерпретатор для выполнения программ на Леха
]]

local lexer = require(script.Parent.lexer)
local parser = require(script.Parent.parser)
local interpreter = require(script.Parent.interpreter)

local main = {}

-- тут ебашим программу
function main.run(source)
	-- ебашим новый экземпляр лексера и токенизируем исходный код
	local lexerInstance = lexer.new(source)
	local tokens = lexerInstance:tokenize()

	-- ебашим новый экземпляр парсера и разбираем токены в AST
	local parserInstance = parser.new(tokens)
	local ast = parserInstance:parse()

	-- ебашим новый экземпляр интерпретатора и выполняем AST
	local interpreterInstance = interpreter.new()
	return interpreterInstance:interpret(ast)
end

-- тесты тут
function main.run_tests()
	print("запуск тестов")

	-- 1: Hello World
	print("\nтест 1: Hello World")
	local hello_world = [[
здарова helloworld.lexa
ебаника "Hello, World!" стоять
давай бб
]]
	print("\nисходный код:")
	print(hello_world)
	print("\nрезультат:")
	print(main.run(hello_world))

	-- 2: Функция Фибоначчи
	print("\nтест 2: функц. Фибоначчи")
	local fibonacci = [[
здарова fibonacci.lexa
//// это комментарий
////!!! а это
комментарий
с линиями
!!!////

хуйняебаная фиб(н)
    если н <= 0 тогда уёбывай 0 похуй стоять
    если н == 1 тогда уёбывай 1 похуй стоять
    уёбывай фиб(н-1) + фиб(н-2) стоять
похуй стоять

//// использование:
для_каждого и = 0, 10 ебашьследующее
    ебаника "Fib(" .. и .. ") = " .. фиб(и) стоять
похуй стоять
давай бб
]]

	print("\nисходный код:")
	print(fibonacci)
	print("\nрезультат:")
	print(main.run(fibonacci))

	-- 3: таблица умножения
	print("\nтест 3: Таблица умножения")
	local multiplication_table = [[
здарова multiplicationtable.lexa
//// простенькая 5х5 таблица
для_каждого и = 1, 5 ебашьследующее
    нарик линия = "" стоять
    для_каждого д = 1, 5 ебашьследующее
        линия = линия .. (и * д) .. "\t" стоять
    похуй стоять
    ебаника линия стоять
похуй стоять
давай бб
]]
	print("\nисходный код:")
	print(multiplication_table)
	print("\nрезультат:")
	print(main.run(multiplication_table))

	print("\nвсё ок")
end

-- запуск примера с математическими операциями
function main.run_math_example()
	print("\nзапуск примера с математическими операциями:")

	local math_example = [[
здарова mathexample.lexa
//// демонстрация мат. операций
нарик а = 10 стоять
нарик б = 5 стоять

ебаника "а = " .. а стоять
ебаника "б = " .. б стоять

ебаника "а + б = " .. (а + б) стоять
ебаника "а - б = " .. (а - б) стоять
ебаника "а * б = " .. (а * б) стоять
ебаника "а / б = " .. (а / б) стоять

нарик пизда = (а + б) * (а - б) / 5 стоять
ебаника "выражение пизда = " .. пизда стоять
давай бб
]]

	print("\nисходный код:")
	print(math_example)
	print("\nрезультат:")
	print(main.run(math_example))
end

-- запуск примера с условиями
function main.run_conditions_example()
	print("\nзапуск примера с условиями:")

	local conditions_example = [[
здарова conditions.lexa
нарик х = 42 стоять

если х > 50 тогда
    ебаника "х больше 50" стоять
похуй стоять

если х < 50 тогда
    ебаника "х меньше 50" стоять
похуй стоять

если х == 42 тогда
    ебаника "СОРОК ДВАААА БРАТУХААААААААААААА" стоять
похуй стоять

//// вложенные условия
если х > 0 тогда
    ебаника "х натуральное число" стоять
    если х % 2 == 0 тогда
        ебаника "х четный" стоять
    похуй стоять
похуй стоять
давай бб
]]

	print("\nисходный код:")
	print(conditions_example)
	print("\nрезультат:")
	print(main.run(conditions_example))
end

-- запуск примера с функциями
function main.run_functions_example()
	print("\nзапуск примера с функциями:")

	local functions_example = [[
здарова functions.lexa
хуйняебаная квадрат(х)
    уёбывай х * х стоять
похуй стоять

хуйняебаная куб(х)
    уёбывай х * х * х стоять
похуй стоять

хуйняебаная факториал(н)
    если н <= 1 тогда
        уёбывай 1 похуй стоять
    уёбывай н * факториал(н - 1) стоять
похуй стоять

ебаника "квадрат 5: " .. квадрат(5) стоять
ебаника "куб 3: " .. куб(3) стоять
ебаника "факториал 5: " .. факториал(5) стоять

ебаника "сложное выражение: " .. (квадрат(3) + куб(2)) стоять
давай бб
]]

	print("\nисходный код:")
	print(functions_example)
	print("\nрезультат:")
	print(main.run(functions_example))
end

-- хочу себе девушку программиста
-- буду её целовать и цветы дарить
function main.run_additional_examples()
	main.run_math_example()
	main.run_conditions_example()
	main.run_functions_example()
end

return main
