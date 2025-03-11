-- ServerScriptService/Лёха/interpreter.lua

--[[
интерпретатор для языка программирования Леха
этот модуль выполняет абстрактное синтаксическое дерево (AST), созданное парсером
он реализует стек-машину с байткодом для выполнения программ Леха
]]

local Interpreter = {}

-- опкоды для виртуальной машины
Interpreter.OPCODES = {
	LOAD_CONST = 1,    -- загрузить константу на стек
	LOAD_VAR = 2,      -- загрузить значение переменной на стек
	STORE_VAR = 3,     -- сохранить значение со стека в переменную
	BINARY_OP = 4,     -- выполнить бинарную операцию над двумя значениями на стеке
	UNARY_OP = 5,      -- выполнить унарную операцию над значением на стеке
	PRINT = 6,         -- вывести значение со стека
	JUMP = 7,          -- перейти к другой инструкции
	JUMP_IF_FALSE = 8, -- перейти, если значение на стеке ложно
	CALL = 9,          -- вызвать функцию
	RETURN = 10,       -- вернуться из функции
	POP = 11           -- удалить значение со стека
}

-- константы для управления стеком
Interpreter.STACK_SIZE = 1000  -- максимальный размер стека

-- создание нового экземпляра интерпретатора
function Interpreter.new()
	local interpreter = {
		code = {},          -- скомпилированный байт-код
		constants = {},     -- полный пул констант
		globals = {},       -- глобальные переменные
		functions = {},     -- определения функций
		stack = {},         -- стек выполнения
		stack_top = 0,      -- указатель стека
		frames = {},        -- кадры вызовов функций
		frame_index = 0,    -- индекс текущего кадра
		ip = 1,             -- указатель инструкции
		output = {},        -- захваченный вывод
		debug_mode = false  -- режим отладки
	}

	-- устанавливаем метатаблицу для использования функций Interpreter
	setmetatable(interpreter, { __index = Interpreter })

	return interpreter
end

-- ёбнуть значение на стек
function Interpreter:push(value)
	-- проверяем переполнение стека
	if self.stack_top >= self.STACK_SIZE then
		error("stack overflow")
	end

	-- увеличиваем указатель и ебашим значение на стек
	self.stack_top = self.stack_top + 1
	self.stack[self.stack_top] = value
end

-- снять значение со стека
function Interpreter:pop()
	-- проверяем опустошение стека
	if self.stack_top <= 0 then
		error("stack underflow")
	end

	-- получаем значение, удаляем его и уменьшаем указатель
	local value = self.stack[self.stack_top]
	
	self.stack[self.stack_top] = nil
	self.stack_top = self.stack_top - 1

	return value
end

-- посмотреть значение на стеке без снятия
function Interpreter:peek(offset)
	offset = offset or 0
	local index = self.stack_top - offset

	-- проверяем опустошение стека
	if index <= 0 then
		error("stack underflow")
	end

	return self.stack[index]
end

-- создать новый кадр вызова функции
function Interpreter:push_frame(function_name, return_ip)
	-- увеличиваем индекс кадра и создаем новый кадр
	self.frame_index = self.frame_index + 1
	
	self.frames[self.frame_index] = {
		function_name = function_name,  -- имя функции
		locals = {},                    -- локальные переменные
		return_ip = return_ip           -- адрес возврата
	}
end

-- удалить текущий кадр вызова функции
function Interpreter:pop_frame()
	-- проверяем опустошение стека кадров
	if self.frame_index <= 0 then
		error("Опустошение стека кадров")
	end

	-- получаем кадр, удаляем его и уменьшаем индекс
	local frame = self.frames[self.frame_index]
	self.frames[self.frame_index] = nil
	self.frame_index = self.frame_index - 1

	return frame
end

-- получить текущий кадр вызова функции
function Interpreter:current_frame()
	if self.frame_index <= 0 then
		return nil
	end

	return self.frames[self.frame_index]
end

-- хуйнуть инструкцию в байт-код
function Interpreter:emit(opcode, ...)
	local operands = {...}
	
	table.insert(self.code, {opcode = opcode, operands = operands})
	return #self.code
end

-- хуйнуть константу в полный пул констант
function Interpreter:add_constant(value)
	table.insert(self.constants, value)
	return #self.constants
end

-- ебашим узел AST в байт-код
function Interpreter:compile_node(node)
	-- проверяем, что узел существует
	if not node then
		return
	end

	-- ебашим узел в зависимости от его типа
	-- боже дай мне сил...
	if node.type == "Program" then
		-- ебашим каждый оператор в программе
		for _, statement in ipairs(node.statements) do
			self:compile_node(statement)
		end
	elseif node.type == "PrintStatement" then
		-- ебашим выражение для вывода
		self:compile_node(node.expression)
		
		-- хуячим инструкцию PRINT
		self:emit(self.OPCODES.PRINT)
	elseif node.type == "BinaryOperation" then
		-- ебашим левый и правый операнды
		self:compile_node(node.left)
		self:compile_node(node.right)
		
		-- хуячим инструкцию BINARY_OP с оператором
		self:emit(self.OPCODES.BINARY_OP, node.operator)
	elseif node.type == "UnaryOperation" then
		-- ебашим операнд
		self:compile_node(node.operand)
		
		-- хуячим инструкцию UNARY_OP с оператором
		self:emit(self.OPCODES.UNARY_OP, node.operator)
	elseif node.type == "NumberLiteral" then
		-- хуячим число в полный пул констант
		local const_index = self:add_constant(node.value)
		
		-- хуячим инструкцию LOAD_CONST с индексом константы
		self:emit(self.OPCODES.LOAD_CONST, const_index)
	elseif node.type == "StringLiteral" then
		-- хуячим строку в пул констант
		local const_index = self:add_constant(node.value)
		
		-- хуячим инструкцию LOAD_CONST с индексом константы
		self:emit(self.OPCODES.LOAD_CONST, const_index)
	elseif node.type == "Variable" then
		-- хуячим инструкцию LOAD_VAR с именем переменной
		self:emit(self.OPCODES.LOAD_VAR, node.name)
	elseif node.type == "Assignment" then
		-- ебашим всё выражение для присваивания
		self:compile_node(node.value)
		
		-- хуячим инструкцию STORE_VAR с именем переменной
		self:emit(self.OPCODES.STORE_VAR, node.target)
	elseif node.type == "VariableDeclaration" then
		-- ебашим выражение для присваивания
		self:compile_node(node.value)
		
		-- хуячим инструкцию STORE_VAR с именем переменной
		self:emit(self.OPCODES.STORE_VAR, node.name)
	elseif node.type == "IfStatement" then
		-- ебашим условие
		self:compile_node(node.condition)

		-- хуячим инструкцию JUMP_IF_FALSE с адресом перехода
		-- потом пропатчим ваще похуй.
		local jump_if_false_pos = self:emit(self.OPCODES.JUMP_IF_FALSE, 0)

		-- ебашим тело условного оператора
		for _, statement in ipairs(node.body) do
			self:compile_node(statement)
		end

		-- патчим адрес перехода
		self.code[jump_if_false_pos].operands[1] = #self.code + 1
	elseif node.type == "ForLoop" then
		-- ебашим начальное значение
		self:compile_node(node.start)
		
		-- сохраняем его в переменной цикла
		self:emit(self.OPCODES.STORE_VAR, node.variable)

		-- вот тута позиция начала цикла
		local loop_start_pos = #self.code + 1

		-- загружаем переменную цикла
		self:emit(self.OPCODES.LOAD_VAR, node.variable)
		
		-- ебашим конечное значение
		self:compile_node(node.finish)
		
		-- сравниваем: переменная цикла <= конечное значение
		self:emit(self.OPCODES.BINARY_OP, "<=")

		-- хуячим инструкцию JUMP_IF_FALSE с адресом выхода из цикла
		-- потом пропатчим ваще похуй.
		local jump_out_pos = self:emit(self.OPCODES.JUMP_IF_FALSE, 0)

		-- ебашим тело цикла
		for _, statement in ipairs(node.body) do
			self:compile_node(statement)
		end

		-- увеличиваем переменную цикла
		self:emit(self.OPCODES.LOAD_VAR, node.variable)
		
		local const_index = self:add_constant(1)
		
		self:emit(self.OPCODES.LOAD_CONST, const_index)
		self:emit(self.OPCODES.BINARY_OP, "+")
		
		self:emit(self.OPCODES.STORE_VAR, node.variable)

		-- хуячим инструкцию JUMP для возврата к началу цикла
		self:emit(self.OPCODES.JUMP, loop_start_pos)

		-- патчим адрес выхода из цикла
		self.code[jump_out_pos].operands[1] = #self.code + 1
	elseif node.type == "FunctionDefinition" then
		-- вот тута текущая позиция мяу
		local current_pos = #self.code

		-- хуячим инструкцию JUMP для пропуска тела функции
		local jump_over_pos = self:emit(self.OPCODES.JUMP, 0)

		-- запоминаем позицию начала функции
		local function_start_pos = #self.code + 1

		-- сохраняем определение функции
		self.functions[node.name] = {
			parameters = node.parameters,
			start_pos = function_start_pos
		}

		-- ебашим тело функции
		for _, statement in ipairs(node.body) do
			self:compile_node(statement)
		end

		-- хуячим неявный return nil, если нет явного return
		if #node.body == 0 or node.body[#node.body].type ~= "ReturnStatement" then
			local nil_index = self:add_constant(nil)
			self:emit(self.OPCODES.LOAD_CONST, nil_index)
			self:emit(self.OPCODES.RETURN)
		end

		-- патчим адрес пропуска тела функции
		self.code[jump_over_pos].operands[1] = #self.code + 1
	elseif node.type == "FunctionCall" then
		-- помещаем аргументы на стек (в обратном порядке)
		for i = #node.arguments, 1, -1 do
			self:compile_node(node.arguments[i])
		end

		-- хуячим инструкцию CALL с именем функции и количеством аргументов
		self:emit(self.OPCODES.CALL, node.name, #node.arguments)
	elseif node.type == "ReturnStatement" then
		-- ебашим возвращаемое значение
		self:compile_node(node.value)
		
		-- хуячим инструкцию RETURN
		self:emit(self.OPCODES.RETURN)
	else
		error("Неизвестный тип узла: " .. node.type)
	end
end

-- тут ебашим AST в байт-код
function Interpreter:compile(ast)
	self:compile_node(ast)
	return self.code
end

-- заебашиваем скомпилированный байт-код
function Interpreter:execute()
	-- сбрасываем ваще всё нахуй
	self.stack = {}
	self.stack_top = 0
	self.frames = {}
	self.frame_index = 0
	self.ip = 1
	self.output = {}

	-- выполняем инструкции, пока не закончатся
	while self.ip <= #self.code do
		local instruction = self.code[self.ip]
		local opcode = instruction.opcode
		local operands = instruction.operands

		-- отладочный вывод текущего состояния выполнения
		if self.debug_mode then
			local opcode_name = "UNKNOWN"
			
			for name, code in pairs(self.OPCODES) do
				if code == opcode then
					opcode_name = name
					break
				end
			end
			print("Выполняется " .. opcode_name .. " на IP=" .. self.ip)
		end

		-- выполняем инструкцию в зависимости от ее опкода
		if opcode == self.OPCODES.LOAD_CONST then
			-- загружаем константу на стек
			local const_index = operands[1]
			self:push(self.constants[const_index])
			
			self.ip = self.ip + 1
		elseif opcode == self.OPCODES.LOAD_VAR then
			-- загружаем переменную на стек
			local var_name = operands[1]
			local value

			-- рыпаться нельзя. надо чекнуть является ли это локальной переменной
			local frame = self:current_frame()
			if frame and frame.locals[var_name] ~= nil then
				value = frame.locals[var_name]
			else
				value = self.globals[var_name]
			end

			-- проверяем, что переменная определена
			if value == nil then
				error("неопределенная переменная: " .. var_name)
			end

			self:push(value)
			self.ip = self.ip + 1
		elseif opcode == self.OPCODES.STORE_VAR then
			-- сохраняем значение в переменную
			local var_name = operands[1]
			local value = self:pop()

			-- так нахуй, чекаем является ли это локальной переменной
			local frame = self:current_frame()
			if frame and frame.function_name then
				local func = self.functions[frame.function_name]
				if func and func.parameters and table.concat(func.parameters, ","):find(var_name) then
					-- кароч, это параметр, поэтому это локальная переменная
					frame.locals[var_name] = value
				else
					-- хуйняяяя, не параметр, чекаем если является ли она локальной
					if frame.locals[var_name] ~= nil then
						frame.locals[var_name] = value
					else
						-- ну окей, не локальная значит глобальная
						self.globals[var_name] = value
					end
				end
			else
				-- нет кадра функции, значит глобальная
				self.globals[var_name] = value
			end

			self.ip = self.ip + 1
		elseif opcode == self.OPCODES.BINARY_OP then
			-- выполняем бинарную операцию
			local operator = operands[1]
			local right = self:pop()
			local left = self:pop()
			local result

			-- пошёл нахуй
			if operator == "+" then
				result = left + right
			elseif operator == "-" then
				result = left - right
			elseif operator == "*" then
				result = left * right
			elseif operator == "/" then
				result = left / right
			elseif operator == "==" then
				result = left == right
			elseif operator == "<" then
				result = left < right
			elseif operator == ">" then
				result = left > right
			elseif operator == "<=" then
				result = left <= right
			elseif operator == ">=" then
				result = left >= right
			elseif operator == ".." then
				result = tostring(left) .. tostring(right)
			else
				error("неизвестный бинарный оператор: " .. operator)
			end

			self:push(result)
			self.ip = self.ip + 1
		elseif opcode == self.OPCODES.UNARY_OP then
			-- выполняем операцию вычитания
			local operator = operands[1]
			local operand = self:pop()
			local result

			-- выполняем операцию в зависимости от оператора
			if operator == "-" then
				result = -operand
			elseif operator == "+" then
				result = operand -- унарный плюс нихуя не делает
			else
				error("неизвестный унарный оператор: " .. operator)
			end

			self:push(result)
			self.ip = self.ip + 1
		elseif opcode == self.OPCODES.PRINT then
			-- выводим значение со стека
			local value = self:pop()
			
			table.insert(self.output, tostring(value))
			
			-- эхх...
			if self.debug_mode then
				print("[отладка] вывод: " .. tostring(value))
			end

			self.ip = self.ip + 1
		elseif opcode == self.OPCODES.JUMP then
			-- переходим к указанной инструкции
			self.ip = operands[1]
		elseif opcode == self.OPCODES.JUMP_IF_FALSE then
			-- переходим, если значение на стеке ложно
			local condition = self:pop()

			if not condition then
				self.ip = operands[1]
			else
				self.ip = self.ip + 1
			end
		elseif opcode == self.OPCODES.CALL then
			-- вызываем функцию
			local function_name = operands[1]
			local arg_count = operands[2]
			local func = self.functions[function_name]

			-- проверяем, что функция определена
			if not func then
				error("неопределенная функция: " .. function_name)
			end

			-- создаем новый кадр вызова
			self:push_frame(function_name, self.ip + 1)

			-- устанавливаем параметры как локальные переменные
			local frame = self:current_frame()
			for i = 1, arg_count do
				local param_name = func.parameters[i]
				if param_name then
					frame.locals[param_name] = self:pop()
				else
					-- дохуя аргументов, выбрасываем лишние
					self:pop()
				end
			end

			-- переходим к началу функции
			self.ip = func.start_pos
		elseif opcode == self.OPCODES.RETURN then
			-- возвращаемся из функции
			local return_value = self:pop()
			local frame = self:pop_frame()

			-- ебашим возвращаемое значение на стек
			self:push(return_value)

			-- переходим на адрес возврата
			self.ip = frame.return_ip
		elseif opcode == self.OPCODES.POP then
			-- снимаем значение со стека и отбрасываем его
			self:pop()
			self.ip = self.ip + 1
		else
			error("неизвестный опкод: " .. opcode)
		end
	end

	-- хуячим назад весь вывод программы как строку
	return table.concat(self.output, "\n")
end

-- злата привет ном. 2 :)
function Interpreter:interpret(ast)
	self:compile(ast)
	return self:execute()
end

return Interpreter
