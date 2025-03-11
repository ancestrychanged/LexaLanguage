-- ServerScriptService/Лёха/parser.lua

--[[
cинтаксический анализатор (парсер) для языка программирования Леха
этот модуль преобразует поток токенов в абстрактное синтаксическое дерево (AST)
он реализует правила грамматики языка Леха и создает древовидную структуру,
представляющую смысл программы
]]

local Parser = {}

-- ебашим новый экземпляр парсера
function Parser.new(tokens)
	local parser = {
		tokens = tokens,         -- список токенов от лексера
		current_token_idx = 1,   -- индекс текущего токена
		current_token = nil,     -- текущий обрабатываемый токен
		in_block = false         -- флаг для отслеживания блоков кода
	}

	-- устанавливаем начальный токен
	if #tokens > 0 then
		parser.current_token = tokens[1]
	end

	-- устанавливаем метатаблицу для использования функций Parser
	setmetatable(parser, { __index = Parser })

	return parser
end

-- переход к следующему токену
function Parser:advance()
	-- увеличиваем индекс
	self.current_token_idx = self.current_token_idx + 1

	-- если не достигли конца списка токенов, получаем следующий токен
	if self.current_token_idx <= #self.tokens then
		self.current_token = self.tokens[self.current_token_idx]
	else
		self.current_token = nil
	end

	return self.current_token
end

-- просмотр следующего токена без перехода к нему
function Parser:peek(offset)
	offset = offset or 1
	local peek_idx = self.current_token_idx + offset

	-- если индекс в пределах списка токенов, возвращаем токен
	if peek_idx <= #self.tokens then
		return self.tokens[peek_idx]
	else
		return nil
	end
end

-- проверка текущего токена на соответствие ожидаемому типу и значению
function Parser:eat(type, value, optional)
	-- проверяем, что токен существует
	if not self.current_token then
		error("неожиданный конец файла")
	end

	-- проверяем тип токена
	if self.current_token.type ~= type then
		if optional then
			return false
		end
		error(`ожидался токен типа {type}, получен {self.current_token.type} в строке {self.current_token.line}, столбец {self.current_token.column}`)
	end

	-- если указано значение, проверяем его
	if value and self.current_token.value ~= value then
		if optional then
			return false
		end
		error(`ожидалось значение токена {value}, получено {self.current_token.value} в строке {self.current_token.line}, столбец {self.current_token.column}`)
	end

	-- сохраняем токен, переходим к следующему и возвращаем сохраненный
	local token = self.current_token
	self:advance()
	return token
end

-- проверка текущего токена без перехода к следующему
function Parser:check(type, value)
	-- проверяем, что токен существует
	if not self.current_token then
		return false
	end

	-- проверяем тип токена
	if self.current_token.type ~= type then
		return false
	end

	-- если указано значение, проверяем его
	if value and self.current_token.value ~= value then
		return false
	end

	return true
end

-- теперь можно рыпнуться
function Parser:parse_program()
	-- каждая программа начинается с ключевого слова 'здарова' и имени файла
	self:eat("KEYWORD", "здарова")

	local filename = self:eat("IDENTIFIER").value .. ".lexa"

	-- разбираем операторы до 'давай бб'
	local statements = {}

	while self.current_token and 
		not (self.current_token.type == "KEYWORD" and self.current_token.value == "давай" and 
			self:peek() and self:peek().type == "KEYWORD" and self:peek().value == "бб") do
		table.insert(statements, self:parse_statement())
	end

	-- программа заканчивается ключевыми словами 'давай бб'
	self:eat("KEYWORD", "давай")
	self:eat("KEYWORD", "бб")

	-- создаем узел AST для программы
	return {
		type = "Program",
		filename = filename,
		statements = statements
	}
end

-- разбор оператора
function Parser:parse_statement()
	local statement = nil

	-- разбираем оператор в зависимости от его типа
	-- сука...
	if self.current_token.type == "KEYWORD" then
		if self.current_token.value == "ебаника" then
			-- оператор вывода
			statement = self:parse_print_statement()
		elseif self.current_token.value == "хуйняебаная" then
			-- определение функции
			statement = self:parse_function_definition()
		elseif self.current_token.value == "если" then
			-- условный оператор
			statement = self:parse_if_statement()
		elseif self.current_token.value == "для_каждого" then
			-- цикл for
			statement = self:parse_for_loop()
		elseif self.current_token.value == "нарик" then
			-- объявление переменной
			statement = self:parse_variable_declaration()
		elseif self.current_token.value == "уёбывай" then
			-- оператор возврата
			statement = self:parse_return_statement()

			-- если мы в блоке и следующий токен "похуй", завершаем разбор оператора
			if self.in_block and self:check("KEYWORD", "похуй") then
				return statement
			end
		else
			error(`неожиданное ключ. слово {self.current_token.value}, в строке {self.current_token.line}, столбец {self.current_token.column}`)
		end
	elseif self.current_token.type == "IDENTIFIER" then
		-- присваивание или вызов функции
		local identifier = self:eat("IDENTIFIER").value

		if self.current_token.type == "OPERATOR" and self.current_token.value == "=" then
			-- присваивание
			self:eat("OPERATOR", "=")
			local value = self:parse_expression()

			statement = {
				type = "Assignment",
				target = identifier,
				value = value
			}
		elseif self.current_token.type == "SYMBOL" and self.current_token.value == "(" then
			-- вызов функции
			statement = {
				type = "FunctionCall",
				name = identifier,
				arguments = self:parse_arguments()
			}
		else
			error(`ожидался символ '=' или '(' после идентификатора в строке {self.current_token.line}, стоблец {self.current_token.column}`)
		end
	else
		error(`неожиданный тип токена {self.current_token.type}, в строке {self.current_token.line}, столбец {self.current_token.column}`)
	end

	-- каждый оператор заканчивается 'стоять', если это не return в блоке
	if statement and statement.type ~= "ReturnStatement" then
		self:eat("KEYWORD", "стоять")
	end

	return statement
end

-- разбор оператора вывода
function Parser:parse_print_statement()
	-- обрабатываем ключевое слово 'ебаника'
	self:eat("KEYWORD", "ебаника")

	-- создаем узел AST для оператора вывода
	return {
		type = "PrintStatement",
		expression = self:parse_expression()
	}
end

-- разбор определения функции
function Parser:parse_function_definition()
	-- обрабатываем ключевое слово 'хуйняебаная'
	self:eat("KEYWORD", "хуйняебаная")

	-- получаем имя функции
	local name = self:eat("IDENTIFIER").value

	-- разбираем параметры
	self:eat("SYMBOL", "(")
	local parameters = {}

	if self.current_token.type == "IDENTIFIER" then
		table.insert(parameters, self:eat("IDENTIFIER").value)

		while self.current_token.type == "SYMBOL" and self.current_token.value == "," do
			self:eat("SYMBOL", ",")
			table.insert(parameters, self:eat("IDENTIFIER").value)
		end
	end

	self:eat("SYMBOL", ")")

	-- разбираем тело функции
	local body = {}

	-- устанавливаем флаг блока
	local old_in_block = self.in_block
	self.in_block = true

	-- продолжаем разбор операторов до 'похуй'
	while self.current_token and 
		not (self.current_token.type == "KEYWORD" and self.current_token.value == "похуй") do
		table.insert(body, self:parse_statement())
	end

	-- восстанавливаем прежнее значение флага блока
	self.in_block = old_in_block

	-- обрабатываем закрывающее 'похуй'
	self:eat("KEYWORD", "похуй")

	-- создаем узел AST для определения функции
	return {
		type = "FunctionDefinition",
		name = name,
		parameters = parameters,
		body = body
	}
end

-- разбор условного оператора
function Parser:parse_if_statement()
	-- обрабатываем ключевое слово 'если'
	self:eat("KEYWORD", "если")

	-- разбираем условие
	local condition = self:parse_expression()

	-- обрабатываем ключевое слово 'тогда'
	self:eat("KEYWORD", "тогда")

	-- разбираем тело условного оператора
	local body = {}

	-- устанавливаем флаг блока
	local old_in_block = self.in_block
	self.in_block = true

	-- продолжаем разбор операторов до 'похуй'
	while self.current_token and 
		not (self.current_token.type == "KEYWORD" and self.current_token.value == "похуй") do
		table.insert(body, self:parse_statement())
	end

	-- восстанавливаем прежнее значение флага блока
	self.in_block = old_in_block

	-- обрабатываем закрывающее 'похуй'
	self:eat("KEYWORD", "похуй")

	-- создаем узел AST для условного оператора
	return {
		type = "IfStatement",
		condition = condition,
		body = body
	}
end

-- разбор цикла for
function Parser:parse_for_loop()
	-- обрабатываем ключевое слово 'для_каждого'
	self:eat("KEYWORD", "для_каждого")

	-- получаем имя переменной цикла
	local variable = self:eat("IDENTIFIER").value

	-- обрабатываем знак присваивания
	self:eat("OPERATOR", "=")

	-- разбираем начальное значение
	local start = self:parse_expression()

	-- обрабатываем запятую
	self:eat("SYMBOL", ",")

	-- разбираем конечное значение
	local finish = self:parse_expression()

	-- обрабатываем ключевое слово 'ебашьследующее'
	self:eat("KEYWORD", "ебашьследующее")

	-- разбираем тело цикла
	local body = {}

	-- устанавливаем флаг блока
	local old_in_block = self.in_block
	self.in_block = true

	-- продолжаем разбор операторов до 'похуй'
	while self.current_token and 
		not (self.current_token.type == "KEYWORD" and self.current_token.value == "похуй") do
		table.insert(body, self:parse_statement())
	end

	-- восстанавливаем прежнее значение флага блока
	self.in_block = old_in_block

	-- обрабатываем закрывающее 'похуй'
	self:eat("KEYWORD", "похуй")

	-- создаем узел AST для цикла for
	return {
		type = "ForLoop",
		variable = variable,
		start = start,
		finish = finish,
		body = body
	}
end

-- разбор объявления переменной
function Parser:parse_variable_declaration()
	-- обрабатываем ключевое слово 'нарик'
	self:eat("KEYWORD", "нарик")

	-- получаем имя переменной
	local name = self:eat("IDENTIFIER").value

	-- обрабатываем знак присваивания
	self:eat("OPERATOR", "=")

	-- разбираем значение
	local value = self:parse_expression()

	-- создаем узел AST для объявления переменной
	return {
		type = "VariableDeclaration",
		name = name,
		value = value
	}
end

-- разбор оператора возврата
function Parser:parse_return_statement()
	-- обрабатываем ключевое слово 'уёбывай'
	self:eat("KEYWORD", "уёбывай")

	-- разбираем возвращаемое значение
	local return_value = self:parse_expression()

	-- ожидаем 'стоять' только если не в блоке или если следующий токен не 'похуй'
	if not self.in_block or not self:check("KEYWORD", "похуй") then
		self:eat("KEYWORD", "стоять")
	end

	-- создаем узел AST для оператора возврата
	return {
		type = "ReturnStatement",
		value = return_value
	}
end

-- разбор аргументов вызова функции
function Parser:parse_arguments()
	local arguments = {}

	-- обрабатываем открывающую скобку
	self:eat("SYMBOL", "(")

	-- если следующий токен не закрывающая скобка, разбираем аргументы
	if self.current_token.type ~= "SYMBOL" or self.current_token.value ~= ")" then
		table.insert(arguments, self:parse_expression())

		-- разбираем остальные аргументы, разделенные запятыми
		while self.current_token.type == "SYMBOL" and self.current_token.value == "," do
			self:eat("SYMBOL", ",")
			table.insert(arguments, self:parse_expression())
		end
	end

	-- обрабатываем закрывающую скобку
	self:eat("SYMBOL", ")")

	return arguments
end

-- разбор выражения
function Parser:parse_expression()
	-- выражения разбираются в порядке приоритета операций
	return self:parse_concatenation()
end

-- разбор операции конкатенации строк
function Parser:parse_concatenation()
	-- разбираем левую часть выражения
	local left = self:parse_comparison()

	-- если следующий токен оператор '..' (конкат), обрабатываем его
	while self.current_token and 
		self.current_token.type == "OPERATOR" and 
		self.current_token.value == ".." do
		local operator = self:eat("OPERATOR").value
		local right = self:parse_comparison()

		-- создаем узел AST для бинарной операции
		-- злата привет :)
		left = {
			type = "BinaryOperation",
			operator = operator,
			left = left,
			right = right
		}
	end

	return left
end

-- разбор операций сравнения
function Parser:parse_comparison()
	-- разбираем левую часть выражения
	local left = self:parse_addition()

	-- если следующий токен оператор сравнения, обрабатываем его
	if self.current_token and 
		self.current_token.type == "OPERATOR" and 
		(self.current_token.value == "==" or 
			self.current_token.value == "<" or 
			self.current_token.value == ">" or 
			self.current_token.value == "<=" or 
			self.current_token.value == ">=") then
		local operator = self:eat("OPERATOR").value
		local right = self:parse_addition()

		-- создаем узел AST для операции сравнения
		return {
			type = "BinaryOperation",
			operator = operator,
			left = left,
			right = right
		}
	end

	return left
end

-- разбор операций сложения и вычитания
function Parser:parse_addition()
	-- разбираем левую часть выражения
	local left = self:parse_multiplication()

	-- если следующий токен оператор + или -, обрабатываем его
	while self.current_token and 
		self.current_token.type == "OPERATOR" and 
		(self.current_token.value == "+" or self.current_token.value == "-") do
		local operator = self:eat("OPERATOR").value
		local right = self:parse_multiplication()

		-- создаем узел AST для операции сложения или вычитания
		left = {
			type = "BinaryOperation",
			operator = operator,
			left = left,
			right = right
		}
	end

	return left
end

-- разбор операций умножения и деления
function Parser:parse_multiplication()
	-- разбираем первичное выражение
	local left = self:parse_primary()

	-- если следующий токен оператор * или /, обрабатываем его
	while self.current_token and 
		self.current_token.type == "OPERATOR" and 
		(self.current_token.value == "*" or self.current_token.value == "/") do
		local operator = self:eat("OPERATOR").value
		local right = self:parse_primary()

		-- создаем узел AST для операции умножения или деления
		left = {
			type = "BinaryOperation",
			operator = operator,
			left = left,
			right = right
		}
	end

	return left
end

-- разбор первичных выражений (литералы, идентификаторы, вызовы функций и т.д.)
function Parser:parse_primary()
	-- обрабатываем различные типы первичных выражений
	if self.current_token.type == "NUMBER" then
		-- числовой литерал
		return {
			type = "NumberLiteral",
			value = self:eat("NUMBER").value
		}
	elseif self.current_token.type == "STRING" then
		-- строковый литерал
		return {
			type = "StringLiteral",
			value = self:eat("STRING").value
		}
	elseif self.current_token.type == "IDENTIFIER" then
		-- идентификатор (переменная или функция)
		local identifier = self:eat("IDENTIFIER").value

		if self.current_token.type == "SYMBOL" and self.current_token.value == "(" then
			-- вызов функции
			return {
				type = "FunctionCall",
				name = identifier,
				arguments = self:parse_arguments()
			}
		else
			-- ссылка на переменную
			return {
				type = "Variable",
				name = identifier
			}
		end
	elseif self.current_token.type == "SYMBOL" and self.current_token.value == "(" then
		-- выражение в скобках
		self:eat("SYMBOL", "(")
		local expr = self:parse_expression()
		self:eat("SYMBOL", ")")
		return expr
	elseif self.current_token.type == "OPERATOR" and 
		(self.current_token.value == "+" or self.current_token.value == "-") then
		-- операция вычитания
		local operator = self:eat("OPERATOR").value
		local operand = self:parse_primary()

		-- создаем узел AST для операции вычитания
		return {
			type = "UnaryOperation",
			operator = operator,
			operand = operand
		}
	else
		error(`неожиданный токен в выражении; в строке {self.current_token.line}, столбец {self.current_token.column}`)
	end
end

-- ну всё ебать разбираем программу
function Parser:parse()
	return self:parse_program()
end

return Parser
