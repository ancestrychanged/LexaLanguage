-- ServerScriptService/Лёха/lexer.lua

--[[
лексический анализатор для языка программирования Леха
этот модуль преобразует исходный код в поток токенов,
которые затем могут быть обработаны парсером
]]

local Lexer = {}

-- типы токенов
Lexer.TOKEN_TYPES = {
	KEYWORD = "KEYWORD",        -- ключевые слова языка (здарова, ебаника, стоять и т.д.)
	IDENTIFIER = "IDENTIFIER",  -- имена переменных и функций
	STRING = "STRING",          -- строковые литералы
	NUMBER = "NUMBER",          -- числовые литералы
	OPERATOR = "OPERATOR",      -- операторы (+, -, *, / и т.д.)
	SYMBOL = "SYMBOL",          -- скобки, запятые и т.д.
	COMMENT = "COMMENT",        -- комментарии (не включаются в итоговый поток токенов)
	EOF = "EOF"                 -- конец файла
}

-- ключевые слова
Lexer.KEYWORDS = {
	["здарова"] = true,         -- начало программы
	["давай"] = true,           -- часть конца программы
	["бб"] = true,              -- часть конца программы
	["стоять"] = true,          -- окончание оператора: ;
	["ебаника"] = true,         -- оператор вывода: print
	["хуйняебаная"] = true,     -- определение функции: function
	["если"] = true,            -- условный оператор: if
	["тогда"] = true,           -- часть условного оператора: then
	["уёбывай"] = true,         -- оператор возврата: return
	["похуй"] = true,           -- окончание блока: end
	["для_каждого"] = true,     -- инициализация цикла: for
	["ебашьследующее"] = true,  -- обозначение итерации цикла: do
	["нарик"] = true            -- объявление переменной: local
}

-- создание нового лексера
function Lexer.new(source)
	-- ебашим объект лексера с начальными параметрами
	local lexer = {
		source = source,         -- исходный код для токенизации
		position = 1,            -- текущая позиция в исходном коде
		line = 1,                -- текущий номер строки
		column = 1,              -- текущий номер столбца
		current_char = nil,      -- текущий обрабатываемый символ
		tokens = {},             -- список токенов
		expect_filename = false  -- флаг, указывающий, что ожидается имя файла
	}

	-- тута получаем первый символ
	if #source > 0 then
		lexer.current_char = string.sub(source, lexer.position, lexer.position)
	end

	-- устанавливаем метатаблицу для использования функций Lexer
	setmetatable(lexer, { __index = Lexer })

	return lexer
end

-- переход к следующему символу
function Lexer:advance()
	-- увеличиваем позицию
	self.position = self.position + 1

	-- если не достигли конца исходного кода, получаем следующий символ
	if self.position <= #self.source then
		self.current_char = string.sub(self.source, self.position, self.position)

		-- обновляем номер строки и столбца
		if self.current_char == '\n' then
			self.line = self.line + 1
			self.column = 1
		else
			self.column = self.column + 1
		end
	else
		-- достигли конца файла
		self.current_char = nil
	end
end

-- просмотр следующего символа без перехода к нему
function Lexer:peek(offset)
	offset = offset or 1
	local peek_pos = self.position + offset

	-- если позиция в пределах исходного кода то тогда возвращаем символ
	if peek_pos <= #self.source then
		return string.sub(self.source, peek_pos, peek_pos)
	else
		return nil
	end
end

-- пропуск пробельных символов
function Lexer:skip_whitespace()
	-- пока текущий символ - пробельный, переходим к следующему
	while self.current_char and string.match(self.current_char, "%s") do
		self:advance()
	end
end

-- обработка комментариев (однострочных и многострочных)
function Lexer:skip_comment()
	-- проверяем, что начинается комментарий (////)
	if self.current_char == '/' and self:peek() == '/' and 
		self:peek(2) == '/' and self:peek(3) == '/' then
		-- пропускаем "////"
		self:advance() self:advance() self:advance() self:advance()

		-- проверяем, многострочный ли это комментарий (///!!!)
		if self.current_char == '!' and self:peek() == '!' and self:peek(2) == '!' then
			-- многострочный комментарий: ////!!! ... !!!////
			self:advance() self:advance() self:advance() -- Пропускаем '!!!'

			-- продолжаем, пока не найдем маркер конца комментария !!!////
			while self.current_char do
				if self.current_char == '!' and 
					self:peek() == '!' and 
					self:peek(2) == '!' and 
					self:peek(3) == '/' and 
					self:peek(4) == '/' and 
					self:peek(5) == '/' and 
					self:peek(6) == '/' then
					-- найден конец многострочного комментария
					for i = 1, 7 do self:advance() end -- пропускается '!!!//// '
					return
				end
				self:advance()
			end
		else
			-- однострочный комментарий: //// ... (до конца строки)
			while self.current_char and self.current_char ~= '\n' do
				self:advance()
			end
			-- пропускаем символ новой строки
			if self.current_char then self:advance() end
		end
	end
end

-- обработка идентификаторов и ключевых слов
function Lexer:identifier()
	local start_pos = self.position
	local id = ""

	-- собираем все буквенно-цифровые символы, подчеркивания или UTF-8 символы
	-- если ожидается имя файла, также принимаем точки
	local allowPeriod = self.expect_filename

	while self.current_char and (
		string.match(self.current_char, "[%w_]") or 
			(allowPeriod and self.current_char == ".") or
			string.byte(self.current_char) > 127) do
		id = id .. self.current_char
		self:advance()
	end

	-- сбрасываем флаг ожидания имени файла
	self.expect_filename = false

	-- проверяем, является ли идентификатор ключевым словом
	local token_type = self.KEYWORDS[id] and self.TOKEN_TYPES.KEYWORD or self.TOKEN_TYPES.IDENTIFIER

	-- если это ключевое слово "здарова", устанавливаем флаг ожидания имени файла
	if id == "здарова" then
		self.expect_filename = true
	end

	-- возвращаем токен
	return {
		type = token_type,
		value = id,
		line = self.line,
		column = self.column - (#id)
	}
end

-- обработка числовых литералов
function Lexer:number()
	local num = ""
	local has_decimal = false

	-- собираем все цифры и максимум одну десятичную точку потому что я так сказал
	while self.current_char and (
		string.match(self.current_char, "%d") or 
			(self.current_char == "." and not has_decimal)) do
		if self.current_char == "." then
			has_decimal = true
		end
		num = num .. self.current_char
		self:advance()
	end

	-- возвращаем числовой токен
	return {
		type = self.TOKEN_TYPES.NUMBER,
		value = tonumber(num),
		line = self.line,
		column = self.column - #tostring(num)
	}
end

-- обработка строковых литералов
function Lexer:string()
	local str = ""

	-- пропускаем открывающую кавычку
	self:advance()

	-- собираем все символы до закрывающей кавычки
	while self.current_char and self.current_char ~= '"' do
		-- обрабатываем escape-последовательности
		if self.current_char == '\\' then
			self:advance()
			if self.current_char == 'n' then
				str = str .. '\n'
			elseif self.current_char == 't' then
				str = str .. '\t'
			elseif self.current_char == '"' then
				str = str .. '"'
			elseif self.current_char == '\\' then
				str = str .. '\\'
			else
				str = str .. '\\' .. self.current_char
			end
		else
			str = str .. self.current_char
		end
		self:advance()
	end

	-- пропускаем закрывающую кавычку
	if self.current_char == '"' then
		self:advance()
	else
		error(`незавершённый строковый литерал в строке {self.line}, столбец {self.column}`)
	end

	-- возвращаем строковый токен
	return {
		type = self.TOKEN_TYPES.STRING,
		value = str,
		line = self.line,
		column = self.column - #str - 2 -- -2 для кавычек
	}
end

-- обработка операторов и символов
function Lexer:operator()
	-- определяем допустимые операторы, включая составные операторы
	local operators = {
		["+"] = true,
		["-"] = true,
		["*"] = true,
		["/"] = true,
		["="] = true,
		["<"] = true,
		[">"] = true,
		["=="] = true,  -- сравнение (равно)
		["<="] = true,  -- сравнение (меньше или равно)
		[">="] = true,  -- сравнение (больше или равно)
		[".."] = true   -- конкат строк
	}

	-- определяем допустимые символы
	local symbols = {
		["("] = true,
		[")"] = true,
		[","] = true
	}

	local op = self.current_char
	local start_column = self.column

	self:advance()

	-- проверяем двухсимвольные операторы
	if (op == "=" and self.current_char == "=") or
		(op == "<" and self.current_char == "=") or
		(op == ">" and self.current_char == "=") or
		(op == "." and self.current_char == ".") then
		op = op .. self.current_char
		self:advance()
	end

	-- возвращаем токен оператора или символа
	if operators[op] then
		return {
			type = self.TOKEN_TYPES.OPERATOR,
			value = op,
			line = self.line,
			column = start_column
		}
	elseif symbols[op] then
		return {
			type = self.TOKEN_TYPES.SYMBOL,
			value = op,
			line = self.line,
			column = start_column
		}
	else
		error(`неизвестный оператор {op} в строке {self.line}, столбец {start_column}`)
	end
end

-- токенизация всего исходного кода
function Lexer:tokenize()
	-- обрабатываем символы, пока не достигнем конца
	while self.current_char do
		-- пропускаем пробельные символы
		if string.match(self.current_char, "%s") then
			self:skip_whitespace()
			-- обрабатываем комментарии
		elseif self.current_char == '/' and self:peek() == '/' and 
			self:peek(2) == '/' and self:peek(3) == '/' then
			self:skip_comment()
			-- обрабатываем идентификаторы и ключевые слова
		elseif string.match(self.current_char, "[%a_]") or string.byte(self.current_char) > 127 then
			table.insert(self.tokens, self:identifier())
			-- обрабатываем числа
		elseif string.match(self.current_char, "%d") then
			table.insert(self.tokens, self:number())
			-- обрабатываем строки
		elseif self.current_char == '"' then
			table.insert(self.tokens, self:string())
			-- обрабатываем операторы и символы
		elseif string.match(self.current_char, "[%+%-%*/=<>%(%)%.,]") then
			table.insert(self.tokens, self:operator())
		else
			error(`неожиданный символ '{self.current_char}' в строке {self.line}, столбец {self.column}`)
		end
	end

	-- добавляем токен конца файла
	table.insert(self.tokens, {
		type = self.TOKEN_TYPES.EOF,
		value = "EOF",
		line = self.line,
		column = self.column
	})

	return self.tokens
end

return Lexer
