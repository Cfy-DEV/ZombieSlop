const ReplicatedStorage = game:GetService("ReplicatedStorage")
const TweenService = game:GetService("TweenService")

local function sever_limb(enemyModule, char, limb, damage)
	local hum = char:FindFirstChildOfClass("Humanoid")
	local info = require(enemyModule)
	if info.IFrames == true then
		return
	end
	local healthInfo = info.Health
	if not healthInfo then
		return
	end
	local find = healthInfo[limb.Name]
	print(find)
	if not find then
		return
	end
	healthInfo[limb.Name] -= damage
	if healthInfo[limb.Name] <= 0 then
		healthInfo[limb.Name] = nil
		local clone = limb:Clone()
		clone.Parent = workspace.Scrap
		clone.CanCollide = true
		if limb.Name == "Head" then
			limb.Transparency = 1
			for e, k in pairs(limb:GetDescendants()) do
				k:Destroy()
			end
		else
			limb:Destroy()
		end
		local vel = Instance.new("BodyVelocity")
		vel.Parent = clone
		vel.MaxForce = Vector3.one * math.huge
		vel.Velocity = Vector3.new(math.random(-20, 20), math.random(30, 60), math.random(-20, 20))
		local angularVelocity = Instance.new("BodyAngularVelocity")
		angularVelocity.MaxTorque = Vector3.one * math.huge
		angularVelocity.AngularVelocity = Vector3.new(math.random(-20, 20), math.random(15, 45), math.random(-20, 20))
		clone.Anchored = false
		task.delay(0.2, function()
			angularVelocity:Destroy()
			vel:Destroy()
		end)
		task.delay(3, function()
			local function vanish(part)
				for i = 1, 20 do
					part.Transparency += 0.05
					task.wait(0.05)
				end
			end
			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					task.spawn(function()
						vanish(part)
					end)
				end
			end
			vanish(clone)
			clone:Destroy()
		end)
	end
	healthInfo.Total = hum.Health
end

return function(damage, hum, limb)
	local char = hum.Parent
	local find = char:FindFirstChild("EnemyStatus")
	local health = hum.Health
	hum:TakeDamage(damage)
	if find and limb ~= nil then
		local req = require(find)
		if req and req.IFrames == true then
			return
		end
		sever_limb(find, char, limb, damage)
	end
	if health < hum.Health then
		return
	end
	if not char or not char:IsA("Model") then
		return
	end
	local hrs = char:FindFirstChild("HumanoidRootPart")
	if not hrs then
		return
	end
	local damageCounter = ReplicatedStorage.Assets.DamageCounter:Clone()
	damageCounter.Parent = workspace
	local billboard: BillboardGui = damageCounter.BillboardGui
	local text = billboard:FindFirstChildOfClass("TextLabel")
	text.Text = "-" .. damage
	damageCounter.Position = hrs.Position
	local t1 = TweenService:Create(damageCounter, TweenInfo.new(1.5, Enum.EasingStyle.Back), {
		Position = damageCounter.Position
			+ Vector3.new(math.random(-10, 20), math.random(-20, 10), math.random(-20, 10)),
	})
	t1:Play()
	local t2 = TweenService:Create(text, TweenInfo.new(1.5), {
		TextTransparency = 1,
	})
	t2:Play()
	t1.Completed:Connect(function(_: Enum.PlaybackState)
		damageCounter:Destroy()
	end)
end
