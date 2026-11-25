--!nocheck

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const SimplePath = require(ReplicatedStorage.Shared.Libs.SimplePath)
const DistanceUtils = require(ReplicatedStorage.Shared.Modules.DistanceUtils)

const attack_damage = 10
const attack_cooldown = 2
const attack_range = 3

local db = false

local lastPosition = nil
local zombie = script.Parent
local hrs: BasePart = zombie.HumanoidRootPart
local humanoid: Humanoid = zombie.Humanoid
zombie.Parent = workspace.Enemies

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

function playSound(sound : Sound, part : BasePart)
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
	newSound.SoundId = idk..id
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
randomRiseAnim.Ended:Wait()

hrs.Anchored = false

local limbPriority = {
	[1] = "Left Leg",
	[2] = "Right Leg",
	[3] = "Left Arm",
	[4] = "Right Arm",
	[5] = "Torso",
}

function attack(char)
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
	if highestPriorityLimb then
		highestPriorityLimb:BreakJoints()
		local clone = highestPriorityLimb:Clone()
		highestPriorityLimb:Destroy()
		clone.Parent = workspace
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
	targetHumanoid:TakeDamage(attack_damage)
end

while task.wait(_G.Tickspeed) do
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
		local Attack: AnimationTrack = loadedAnimations["Attack"]
		Attack.Priority = Enum.AnimationPriority.Action
		Attack:Play()
		attack(char)
	end

	if lastPosition ~= targetHumanoidRootPart.Position then
		lastPosition = targetHumanoidRootPart.Position
		path:Run(targetHumanoidRootPart.Position)
		continue
	end
end
