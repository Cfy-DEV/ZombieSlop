--!nocheck

local module = {}

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const EnemyInfo = require(ReplicatedStorage.Shared.Modules.EnemyInfo)
const enemyFolder: Folder = workspace.Enemies
const Assets = ReplicatedStorage.Assets

function cloneTable(c, t)
	for i, v in pairs(c) do
		t[i] = v
	end
	return t
end

function logic(child)
	local hum = child:FindFirstChildOfClass("Humanoid")
	local find = EnemyInfo[child.Name]
	if not find then
		return
	end
	local currentEnemyInfo: ModuleScript = Assets.ModuleScript:Clone()
	currentEnemyInfo.Name = "EnemyStatus"
    currentEnemyInfo.Parent = child
	local req = require(currentEnemyInfo)
	req.IFrames = false
	cloneTable(find, req)
	local health = req.Health
	hum.MaxHealth = health.Max
	hum.Health = hum.MaxHealth
	hum.WalkSpeed = req.WalkSpeed
	hum.JumpPower = req.JumpPower
end

local t = {}

function module.Init()
	enemyFolder.DescendantAdded:Connect(function(child: Instance)
		local hum : Humanoid = child:FindFirstChildOfClass("Humanoid")
		if not hum or t[hum] then
			return
		end
		t[hum] = true
		logic(child)
	end)
end

return module
