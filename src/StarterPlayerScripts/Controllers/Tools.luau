const ContextActionService = game:GetService("ContextActionService")
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")
const ItensInfo = require(ReplicatedStorage.Shared.Modules.ItensInfo)
local sharedFolder = ReplicatedStorage.Shared
local t = {}

function initTool(tool)
	if not tool:IsA("Tool") or t[tool] then
		return
	end

	local find = sharedFolder.ToolsClient:FindFirstChild(tool.Name)

	if find and not t[tool] then
		t[tool] = true
		local clone = find:Clone()
		clone.Parent = tool
	end
end

for _, inst in pairs(workspace:GetDescendants()) do
	if inst:IsA("Tool") then
		initTool(inst)
	end
end

local currentItemInfo : nil | {Cooldown : number}
local equippedTool : nil | Tool
local holdingMouse = false
local db = {}

ContextActionService:BindAction("UseTool", function(_, inputState: Enum.UserInputState, _)
	if inputState == Enum.UserInputState.Begin then
		holdingMouse = true
		while task.wait() and holdingMouse do
			print(equippedTool, ItensInfo)
			if equippedTool ~= nil and currentItemInfo ~= nil and not db[equippedTool] then
				db[equippedTool] = true
				equippedTool:Activate()
				task.delay(currentItemInfo.Cooldown, function()
					db[equippedTool] = false
				end)
			end
		end
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		holdingMouse = false
	end
end, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonX)

return function()
	workspace.DescendantAdded:Connect(initTool)

	local lp = Players.LocalPlayer
	local mouse = lp:GetMouse()

	while true do
		equippedTool = nil
		local char
		repeat
			char = lp.Character
			task.wait()
		until char ~= nil
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			continue
		end
		local hrp: BasePart = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end

		local lastTick = math.min(tick(), 1)

		while char and not (humanoid.Health <= 0) do
			task.wait()
			local deltaTime = tick() - lastTick
			lastTick = tick()
			local tool : Tool = char:FindFirstChildOfClass("Tool")
			if not tool then
				equippedTool = nil
				humanoid.AutoRotate = true
				continue
			end
			equippedTool = tool
			currentItemInfo = ItensInfo[tool.Name]
			humanoid.AutoRotate = false

			tool.ManualActivationOnly = true

			local pos1 = hrp.Position
			local mousePos = mouse.Hit.Position
			local pos2 = Vector3.new(mousePos.X, pos1.Y, mousePos.Z)
			local lookAt = CFrame.lookAt(pos1, pos2)
			local lerp = hrp.CFrame:Lerp(lookAt, deltaTime * 8)

			hrp.CFrame = lerp
		end
	end
end
