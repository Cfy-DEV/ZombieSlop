const ReplicatedStorage = game:GetService("ReplicatedStorage")
local tool : Tool = script.Parent
if not tool:IsA("Tool") then return end

local GunFired = ReplicatedStorage.Remotes:WaitForChild("GunFired")
local equipped = false

tool.Equipped:Connect(function(_: Mouse)
    equipped = true
end)

tool.Unequipped:Connect(function()
    equipped = false
end)

tool.Activated:Connect(function()
    if not equipped then return end
    GunFired:FireServer()
end)