const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
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

return function()
	workspace.DescendantAdded:Connect(initTool)

	local lp = Players.LocalPlayer
	local mouse = lp:GetMouse()

	while true do
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

		while char do
			task.wait()
			local deltaTime = tick() - lastTick
			lastTick = tick()
			local tool = char:FindFirstChildOfClass("Tool")
			if not tool then
				humanoid.AutoRotate = true
				continue
			end

			humanoid.AutoRotate = false

			local pos1 = hrp.Position
			local mousePos = mouse.Hit.Position
			local pos2 = Vector3.new(mousePos.X, pos1.Y, mousePos.Z)
			local lookAt = CFrame.lookAt(pos1, pos2)
			local lerp = hrp.CFrame:Lerp(lookAt, deltaTime * 8)

			hrp.CFrame = lerp
		end
	end
end
