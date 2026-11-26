--!nocheck

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const TweenService = game:GetService("TweenService")
const Ragdoll = require(ReplicatedStorage.Shared.Libs.Ragdoll)
const SimplePath = require(ReplicatedStorage.Shared.Libs.SimplePath)
const DistanceUtils = require(ReplicatedStorage.Shared.Modules.DistanceUtils)

const attack_damage = 10
const attack_cooldown = 2
const attack_range = 3

local db = false

local lastPosition = nil
local zombie = script.Parent
zombie.Parent = workspace.Enemies
local find
repeat
	task.wait()
	find = zombie:FindFirstChild("EnemyStatus")
until find
local status = require(find)
local hrs: BasePart = zombie.HumanoidRootPart
local humanoid: Humanoid = zombie.Humanoid

for _, part: BasePart in pairs(zombie:GetDescendants()) do
	if part:IsA("BasePart") then
		part.CollisionGroup = "Enemys"
	end
end

local path = SimplePath.new(zombie, {
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = true,
	AgentCanClimb = false,
})

hrs.Anchored = true

function playSound(sound: Sound, part: BasePart)
	local clone = sound:Clone()
	clone.Parent = part
	clone:Play()
	clone.Ended:Connect(function(_: string)
		clone:Destroy()
	end)
end

local idk = "rbxassetid://"

const soundIds = {
	Groan = "127809799844346",
	Snap = "132151829764277",
	Attack = "131125543405500",
}

local sounds = {}

for name, id in pairs(soundIds) do
	local newSound = Instance.new("Sound")
	newSound.SoundId = idk .. id
	sounds[name] = newSound
end

task.spawn(function()
	while task.wait(math.random(25, 38)) do
		playSound(sounds["Groan"], hrs)
	end
end)

const animationIds = {
	Attack = 90230463110937,
	Walk = 101932763201687,
	Idle = 134479100357400,
}

local loadedAnimations = {}

for Name, ID in pairs(animationIds) do
	local Anim = Instance.new("Animation")
	Anim.Name = Name
	Anim.AnimationId = idk .. ID
	local loadedAnim = (humanoid:FindFirstChildOfClass("Animator") or humanoid):LoadAnimation(Anim)
	loadedAnimations[Name] = loadedAnim
end

const riseAnimationIds = {
	[1] = 78362286913822,
	[2] = 131646799392671,
	[3] = 80180164395060,
	[4] = 97077309595814,
}

local loadedRiseAnimations = {}

for Name, ID in pairs(riseAnimationIds) do
	local Anim = Instance.new("Animation")
	Anim.Name = Name
	Anim.AnimationId = idk .. ID
	local loadedAnim = (humanoid:FindFirstChildOfClass("Animator") or humanoid):LoadAnimation(Anim)
	table.insert(loadedRiseAnimations, loadedAnim)
end

humanoid.Running:Connect(function(speed: number)
	local walking: AnimationTrack = loadedAnimations["Walk"]
	walking.Priority = Enum.AnimationPriority.Movement
	local idle: AnimationTrack = loadedAnimations["Idle"]
	idle.Priority = Enum.AnimationPriority.Core
	if speed > 1 then
		if not walking.IsPlaying then
			walking:Play()
		end
		if idle.IsPlaying then
			idle:Stop()
		end
	else
		if walking.IsPlaying then
			walking:Stop()
		end
		if not idle.IsPlaying then
			idle:Play()
		end
	end
end)

local randomRiseAnim: AnimationTrack = loadedRiseAnimations[math.random(1, #riseAnimationIds)]
randomRiseAnim.Priority = Enum.AnimationPriority.Action4
randomRiseAnim:Play()
task.wait(randomRiseAnim.Length)

hrs.Anchored = false

local limbPriority = {
	[1] = "Left Leg",
	[2] = "Right Leg",
	[3] = "Left Arm",
	[4] = "Right Arm",
	[5] = "Torso",
}

function attack(char)
	if not (status.Health["Right Arm"] or status.Health["Left Arm"]) then
		return
	end
	local Attack: AnimationTrack = loadedAnimations["Attack"]
	Attack.Priority = Enum.AnimationPriority.Action
	Attack:Play()
	local targetHumanoid: Humanoid = char:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid then
		return
	end
	local highestPriorityLimb: BasePart
	for _, limbName in ipairs(limbPriority) do
		local find = char:FindFirstChild(limbName)
		if find then
			highestPriorityLimb = find
			break
		end
	end
	if highestPriorityLimb and status.Health["Head"] then
		highestPriorityLimb:BreakJoints()
		local clone = highestPriorityLimb:Clone()
		highestPriorityLimb:Destroy()
		clone.Parent = workspace.Scrap
		clone.CanCollide = true
		local bodyVel = Instance.new("BodyVelocity", clone)
		bodyVel.MaxForce = Vector3.one * math.huge
		bodyVel.Velocity = Vector3.new(math.random(-20, 20), math.random(10, 30), math.random(-20, 20))
		local Angular = Instance.new("BodyAngularVelocity", clone)
		Angular.MaxTorque = Vector3.one * math.huge
		Angular.AngularVelocity = Vector3.new(math.random(-20, 20), math.random(20, 30), math.random(-20, 20))
			* math.random(3, 6)
		task.delay(0.1, function()
			bodyVel:Destroy()
			Angular:Destroy()
		end)
		task.delay(5, function()
			for i = 1, 20 do
				task.wait(0.1)
				clone.Transparency -= 0.05
				clone.Size *= 0.85
			end
			clone:destroy()
		end)
		playSound(sounds["Snap"], clone)
	end
	playSound(sounds["Attack"], hrs)
	local damage = attack_damage
	if not status.Health["Right Arm"] or not status.Health["Left Arm"] then
		damage /= 2
	end
	if not status.Health["Head"] then
		damage /= 3
	end
	targetHumanoid:TakeDamage(attack_damage)
end

local stop = false

humanoid.HealthChanged:Connect(function(newHealth: number)
	if newHealth <= 0 then
		humanoid.MaxHealth = math.huge
		humanoid.Health = humanoid.MaxHealth
	else
		return
	end
	stop = true
	status.IFrames = true
	Ragdoll.ragdoll(zombie)
	local bodyVel = Instance.new("BodyVelocity", hrs)
	bodyVel.MaxForce = Vector3.one * math.huge
	bodyVel.Velocity = Vector3.new(math.random(-20, 20), 45, math.random(-20, 20))
	task.delay(0.2, function()
		bodyVel:Destroy()
	end)
	task.wait(3)
	if status.Health["Head"] then
		Ragdoll.disableRagdoll(zombie)
		stop = false
		status.IFrames = false
		humanoid.MaxHealth = status.Health.Max
		humanoid.Health = humanoid.MaxHealth
	else
		for _, part in pairs(zombie:GetDescendants()) do
			if part:IsA("BasePart") then
				task.spawn(function()
					for i = 1, 20 do
						part.Transparency += 0.05
						task.wait(0.05)
					end
					humanoid.Health = -1
				end)
				task.wait(2)
				zombie:Destroy()
			end
		end
	end
end)

while task.wait(_G.Tickspeed) do
	if stop then
		continue
	end
	local rayPos = hrs.Position
	local rayDir = hrs.CFrame.LookVector * 2
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace.Players, workspace.Enemies, zombie }

	local target, distance = DistanceUtils.getClosestPlayer(hrs.Position)
	if not target then
		continue
	end
	local char = target.Character
	if not char then
		continue
	end
	local targetHumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	if not targetHumanoidRootPart then
		continue
	end
	local raycast = workspace:Raycast(rayPos, rayDir, raycastParams)
	if raycast then
		humanoid.Jump = true
	end

	if distance <= attack_range and not db then
		db = true
		task.delay(attack_cooldown, function()
			db = false
		end)
		attack(char)
	end

	if not status.Health["Head"] then
		local randomPosition = targetHumanoidRootPart.Position
			+ Vector3.new(
				math.random(-humanoid.WalkSpeed, humanoid.WalkSpeed),
				math.random(-humanoid.WalkSpeed, humanoid.WalkSpeed),
				math.random(-humanoid.WalkSpeed, humanoid.WalkSpeed)
			)
		humanoid:MoveTo(randomPosition)
		continue
	end

	if lastPosition ~= targetHumanoidRootPart.Position then
		lastPosition = targetHumanoidRootPart.Position
		path:Run(targetHumanoidRootPart.Position)
		continue
	end
end
