const Players = game:GetService("Players")
const ServerStorage = game:GetService("ServerStorage")
local notShared = ServerStorage.NotShared

local t = {}

function initTool(tool)
	if not tool:IsA("Tool") or t[tool] then
		return
	end

	local find = notShared.ToolsServer:FindFirstChild(tool.Name)

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
end