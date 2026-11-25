const ReplicatedStorage = game:GetService("ReplicatedStorage")
const TweenService = game:GetService("TweenService")
return function(damage, hum)
	local health = hum.Health
	hum:TakeDamage(damage)
	if health < hum.Health then
		return
	end
	local char = hum.Parent
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
		Position = damageCounter.Position + Vector3.new(math.random(-10, 20), math.random(-20, 10), math.random(-20, 10)),
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