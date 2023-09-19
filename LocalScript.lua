
--		█░█ █▀▀ █▀█ ▄▀█ █ █▀█ ▄▀█ █░█░█ █▀  
--		▀▄▀ ██▄ █▀▄ █▀█ █ █▀▀ █▀█ ▀▄▀▄▀ ▄█ 


--REMOVE COREGUI BACKPACK
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local TweenService = game:GetService("TweenService")

--THE GOODIES
local uis = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local char = workspace:WaitForChild(player.Name)
local bp = player.Backpack
local hum = char:WaitForChild("Humanoid")
local frame = script.Parent.Frame
local template = frame.Template
local typing = false
local dead = false

local iconSize = template.Size
local iconBorder = {x = 40, y = 13}

local inputKeys = {}

local inputOrder = {}


local function initBackpackManager()



	local function handleEquip(tool)
		if tool then
			if tool.Parent ~= char then
				hum:EquipTool(tool)
			else
				hum:UnequipTools()
			end
		end
	end
	local existingClones = {} 

	local function createIcons()
		-- Clear existing icons
		for _, child in ipairs(frame:GetChildren()) do
			if child:IsA("Frame") and child ~= template then
				child:Destroy()
			end
		end

		local tools = bp:GetChildren()
		local toolCount = 0  -- Track the number of tools found in the backpack

		for i, tool in ipairs(tools) do
			if tool:IsA("Tool") and not existingClones[tool] then
				local keyName = tostring(toolCount + 1)
				inputKeys[keyName] = { txt = keyName, tool = tool }
				inputOrder[toolCount + 1] = inputKeys[keyName]
				toolCount = toolCount + 1

				if toolCount >= 5 then
					break  -- Limit the number of clones to 5
				end

				existingClones[tool] = true
			end
		end

		local toShow = toolCount
		local totalX = (toShow * (iconSize.X.Offset + iconBorder.x)) + iconBorder.x
		local totalY = iconSize.Y.Offset + (2 * iconBorder.y)

		frame.Size = UDim2.new(0, totalX, 0, totalY)
		frame.Position = UDim2.new(0.5, -totalX / 2, 1, -(totalY + (iconBorder.y * 2)))
		frame.Visible = true

		for i = 1, toolCount do
			local value = inputOrder[i]
			local clone = template:Clone()
			clone.Parent = frame
			clone.Label.Text = value["txt"]
			clone.Name = value["txt"]
			clone.Visible = true

			-- Calculate the position based on icon size and border
			clone.Position = UDim2.new(0, (i - 1) * (iconSize.X.Offset + iconBorder.x), 0, iconBorder.y)

			local tool = value["tool"]
			if tool then
				clone.Tool.Image = tool.TextureId
			end

			-- Add a bounce animation on hover
			local originalPosition = clone.Position
			local hoverPosition = originalPosition + UDim2.new(0, 0, -0.25, 0)

			local bounceDuration = 0.5 -- Adjust the duration as needed

			clone.Tool.MouseEnter:Connect(function()
				clone:TweenPosition(hoverPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, bounceDuration, true)
			end)

			clone.Tool.MouseLeave:Connect(function()
				clone:TweenPosition(originalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, bounceDuration, true)
			end)

			clone.Tool.MouseButton1Down:Connect(function()
				for key, value in pairs(inputKeys) do
					if value["txt"] == clone.Name then
						handleEquip(value["tool"])
					end
				end
			end)
			
			
		end

		template:Destroy()
	end
	
	local function onKeyPress(keyIndex)
		if keyIndex then
			if keyIndex >= 1 and keyIndex <= 9 then
				local value = inputOrder[keyIndex]

				if value and uis:GetFocusedTextBox() == nil then
					local toolToEquip = value["tool"]

					if toolToEquip then
						-- Check if the tool is already equipped, and unequip it if it is
						if toolToEquip.Parent == char then
							hum:UnequipTools()
						else
							hum:EquipTool(toolToEquip)
						end

					end
				end
			end
		else
			-- Handle the Backspace key
		end
	end

	local function handleNewAddition(adding)
		if adding:IsA("Tool") then
			createIcons()  
		end
	end
	
	local function handleRemoval(removing)
		if removing:IsA("Tool") then
			for i, value in ipairs(inputOrder) do
				if value["tool"] == removing then
					table.remove(inputOrder, i)
					createIcons()  
					break
				end
			end
		end
	end

	uis.InputBegan:Connect(function(key)
		if dead == false and typing == false then
			if key.KeyCode == Enum.KeyCode.One then
				onKeyPress(1)
			elseif key.KeyCode == Enum.KeyCode.Two then
				onKeyPress(2)
			elseif key.KeyCode == Enum.KeyCode.Three then
				onKeyPress(3)
			elseif key.KeyCode == Enum.KeyCode.Four then
				onKeyPress(4)
			elseif key.KeyCode == Enum.KeyCode.Five then
				onKeyPress(5)
			elseif key.KeyCode == Enum.KeyCode.Backspace then
				onKeyPress()
			end
		end
	end)

	createIcons()  
end

initBackpackManager()
