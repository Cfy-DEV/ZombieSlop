const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")
const TweenService = game:GetService("TweenService")

const Damage = require(ServerStorage.NotShared.Modules.Damage)
const GunsInfo = require(ReplicatedStorage.Shared.Modules.GunsInfo)
const bullet = ReplicatedStorage.Assets.Bullet

const getMouse: RemoteFunction = ReplicatedStorage.Remotes:WaitForChild("PlayerGetMouse")
local db = {}

return function(plr)
	local char: Model = plr.Character
	if not char then
		return
	end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then
		return
	end
	local info = GunsInfo[tool.Name]
	if not info then
		return
	end
	if not db[plr] then
		db[plr] = {}
	end
	if db[plr][tool.Name] and tick() - db[plr][tool.Name] <= info.Cooldown then
		return
	end
	db[plr][tool.Name] = tick()
	local handle = tool:FindFirstChild("Handle")
	if not handle then
		return
	end
	local find1 = handle:FindFirstChild("ShootHere") or handle
	local mousePos = getMouse:InvokeClient(plr)
	local pos
	if find1:IsA("Attachment") then
		pos = find1.WorldPosition
	elseif find1:IsA("BasePart") then
		pos = find1.Position
	end
	local distance = (pos - mousePos).Magnitude
	for i = 1, info.Bullets do
		local maxOffset = (distance / 100) * info.MaxOffset
		local offset = Vector3.new(
			math.random(-maxOffset * 100, maxOffset * 100) / 100,
			math.random(-maxOffset * 100, maxOffset * 100) / 100,
			math.random(-maxOffset * 100, maxOffset * 100) / 100
		)
		local dir = CFrame.new(pos, mousePos + offset)
		local cloneBullet: BasePart = bullet:Clone()
		cloneBullet.Parent = workspace.Scrap
		cloneBullet.CFrame = dir
		local function destroyBullet()
			cloneBullet.Anchored = true
			cloneBullet.Transparency = 1
			local trail: Trail? = cloneBullet:FindFirstChildOfClass("Trail")
			if trail then
				task.wait(trail.Lifetime)
			end
			cloneBullet:Destroy()
			return
		end
		task.delay(10, function()
			destroyBullet()
		end)
		local hit = {}
		local pierce = info.Pierce
		cloneBullet.Touched:Connect(function(otherPart: BasePart)
			if pierce <= 0 then
				destroyBullet()
				return
			end
			if otherPart:IsDescendantOf(workspace.Players) or otherPart:IsDescendantOf(workspace.Scrap) then
				return
			end
			local target = otherPart.Parent
			if not target then
				return
			end
			if not target:IsA("Model") then
				if not otherPart:IsDescendantOf(workspace.Enemies) then
					destroyBullet()
				end
				return
			end
			local targetHumanoid: Humanoid = target:FindFirstChildOfClass("Humanoid")
			if not targetHumanoid or hit[targetHumanoid] then
				if not otherPart:IsDescendantOf(workspace.Enemies) then
					destroyBullet()
				end
				return
			end
			hit[targetHumanoid] = true
			pierce -= 1
			Damage(info.Damage, targetHumanoid, otherPart)
		end)
		local bodyVelocity = Instance.new("BodyVelocity", cloneBullet)
		bodyVelocity.MaxForce = Vector3.one * math.huge
		bodyVelocity.Velocity = cloneBullet.CFrame.LookVector * info.BulletSpeed
	end
end

-- return {
--     Gun = {
--         Bullets = 1,
--         Damage = 10,
--         Cooldown = .1,
--          Range = 200
--         MaxOffset = 2, -- max offset each 100 studs of distance.
--     }
-- }
