local rep = game:GetService("ReplicatedStorage")
local run = rep:FindFirstChild("Kakanie")

local examples = {}
pcall(function()
	local f = rep.examples
	examples = {
		["hello world"] = require(f["hello_world.lexa"]),
		["fibonacci"] = require(f["fibonnaci.lexa"]),
		["multiplication table"] = require(f["multiplication_table.lexa"])
	}
end)

local frame = script.Parent
local codeBox = frame:FindFirstChild("CodeBox")
local outputBox = frame:FindFirstChild("OutputBox")
local runButton = frame:FindFirstChild("RunButton")
local buttonsFrame = frame:FindFirstChild("ButtonsFrame")

if examples and next(examples) and not buttonsFrame:FindFirstChildOfClass("TextButton") then
	local buttonY = 0.05

	for name, code in pairs(examples) do
		local button = Instance.new("TextButton")
		button.Name = name .. "Button"
		button.Size = UDim2.new(0.9, 0, 0.1, 0)
		button.Position = UDim2.new(0.05, 0, buttonY, 0)
		button.Parent = buttonsFrame
		button.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
		button.Text = name
		button.TextScaled = true

		button.Activated:Connect(function()
			codeBox.Text = code
		end)

		buttonY = buttonY + 0.15
	end
end

runButton.Activated:Connect(function()
	local code = codeBox.Text
	if code == "" then
		outputBox.Text = "ало где код шалава"
		task.wait(3)
		outputBox.Text = "вывод будет здесь"
		return
	end

	local s, r = pcall(function()
		return run:InvokeServer(code)
	end)

	if s then
		outputBox.Text = r or "нихуя нет"
	else
		outputBox.Text = "хуйня: " .. tostring(r)
	end
end)
