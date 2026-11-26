--!nocheck
--[[

Created by thenoodlepoodle123 (@thenoodlepoodle123) aka Noodle

-------------------------------------------------------------

Ragdoll+ Module
Version: 1.1.3

-------------------------------------------------------------

This module is not associated with any other modules, users, or groups. If anyone, other than myself (@thenoodlepoodle123 on Roblox)
claims this module is associated with them, please do not trust this person. 

This module has taken inspiration from others, mainly Dev1n (@ADRENALXNE)'s module, Ragdoll. Check it out when you have a chance!

-------------------------------------------------------------

Ragdoll+ is a module that allows you to ragdoll any character. It is a very simple module to use, requiring the user 
to make only one function call to enable ragdolling and one to disable. It works fluidly, and can be incoporated into
games easily. It works on R6 and R15.

-------------------------------------------------------------

Examples:

Keep in mind these are just examples to show how you COULD write the code. You can do it any other way as long as you
use the ragdoll and disableRagdoll function.

Example for enabling:
	
	local RagdollModule = (game.ReplicatedStorage.RagdollModule)

	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			RagdollModule.ragdoll(character)
		end)
	end

Example for disabling:
	
	local RagdollModule = (game.ReplicatedStorage.RagdollModule)
	
	RagdollModule.disableRagdoll(character) --You would need to define character somewhere else first.

-------------------------------------------------------------

KEEP IN MIND: You must have a client sided call of humanoid:ChangeState(Enum.HumanoidStateType.Physics) for when the character
ragdolls, and a humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) for when disabling the ragdoll. If you do not have
this, the character may appear to be floating. This can be easily done using RemoteEvents:

THESE ARE EXAMPLES FOR PEOPLE WHO MAY HAVE TROUBLE WITH REMOTE EVENTS, DO NOT FEEL LIKE YOU HAVE TO USE THIS. I do not suggest
using these examples in your code, rather you should customize it with your system. This is just to help you grasp an 
understanding of what to do.

For this example, you would need two remote events in ReplicatedStorage; RagdollEvent and DisableRagdoll.

character and player would have to be defined somewhere in the server script (you could use Players.PlayerAdded for example).

SERVER SIDE:

	RagdollModule.ragdoll(character)

	game.ReplicatedStorage.RagdollEvent:FireClient(player)
	
	task.wait(5)
	RagdollModule.disableRagdoll(character)
	
	game.ReplicatedStorage.DisableRagdoll:FireClient(player)

CLIENT SIDE:

	game.ReplicatedStorage.RagdollEvent.OnClientEvent:Connect(function()
		local humanoid = game.Players.LocalPlayer.Character.Humanoid
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end)
	
	game.ReplicatedStorage.DisableRagdoll.OnClientEvent:Connect(function()
		local humanoid = game.Players.LocalPlayer.Character.Humanoid
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end)

-------------------------------------------------------------

Thanks for using the module!!

]]


export type RagdollCompletions = { --This is for when you call a function outside the script, it shows the parameters and the description of the function while typing.
	ragdoll: typeof(
		--Ragdoll the character you choose.
		function(character: Model) end
	),
	disableRagdoll: typeof(
		--Disable ragdoll for the character you choose. If a player is not ragdolled, nothing will happen.
		function(character: Model) end
	),
	controlStates: typeof(
		--Control the WalkSpeed, JumpPower, etc. You may use this outside the ragdoll script if necessary.
		function (humanoid: Humanoid, characterPrimaryPart: BasePart?, walkSpeed: number, jumpPower: number, autoRotate: boolean, headCanCollide: boolean) end
	),
	checkIfRagdolled: typeof(
		--Checks the state (ragdolled = true, not ragdolled = false) of the character inputted
		function(character: Model) : boolean end
	)
}

local RagdollModule = {} --Initialize the actual module table

RagdollModule.currentlyRagdolled = {} --Table with all the players that have been ragdolled, returns true for the player if ragdolled and false if not
RagdollModule.Motors = {} --Table for the motors in a character

RagdollModule.constraints = { --Table for all the constraints that need to be created to ragdoll the character
	Knee = "HingeConstraint",
	Hip = "BallSocketConstraint",
	Neck = "BallSocketConstraint",
	Shoulder = "BallSocketConstraint",
	Ankle = "HingeConstraint",
	Elbow = "HingeConstraint",
	Root = "RigidConstraint",
	Waist = "BallSocketConstraint",
	Wrist = "HingeConstraint"
}

RagdollModule.existingConstraints = {} --Table to keep track of the current existing constraints (for destruction when not ragdolled)

local defaultWalkSpeed = 16 --Change based on the default walk speed of your experience
local defaultJumpPower = 50.145 --Change if you're using jump height or if you've changed the default jump power

function RagdollModule.ragdoll(character: Model) --The actual ragdoll function
	if not character or RagdollModule.checkIfRagdolled(character) then return end --If the character is nil or is already ragdolled, don't run the function
	
	RagdollModule._initializeConstraints(character) --Start creating the constraints
	
	local characterPrimaryPart : BasePart? = character.PrimaryPart
	local humanoid : Humanoid = character.Humanoid

	RagdollModule.controlStates(humanoid, characterPrimaryPart, 0, 0, false, true) --WalkSpeed, JumPower, etc.
	
	RagdollModule.currentlyRagdolled[character] = true --Set the table value to true (so we know they are ragdolled)
	
	RagdollModule._changeHumanoidState(character, Enum.HumanoidStateType.Physics) --Changes the humanoid state to the one listed in the parameters
end

function RagdollModule._initializeConstraints(character: Model) --Start creating the constraints
	if not character then return end --Don't run the function if the character is nil
	
	if not RagdollModule.Motors[character] then --If there isn't already a motors table, create one
		RagdollModule._setMotorsTable(character)
	end
	
	if not RagdollModule.existingConstraints[character] then --If there isn't already an existingConstraints table for the character, create one.
		RagdollModule.existingConstraints[character] = {}
	end

	for _, descendant in character:GetDescendants() do
		if not descendant:IsA("Motor6D") then continue end
		
		local attachment0 = Instance.new("Attachment") --New attachment for the motor
		attachment0.Parent = descendant.Part0
		attachment0.CFrame = descendant.C0
		
		local attachment1 = Instance.new("Attachment") --Another attachment for the motor
		attachment1.Parent = descendant.Part1
		attachment1.CFrame = descendant.C1
		
		local newName = descendant.Name:gsub("Right", ""):gsub("Left", ""):gsub('Joint', ''):gsub(" ", "") --Sub out all of the unnecessary things in the name for indexing with the table
		
		local constraint = RagdollModule.constraints[newName] or "BallSocketConstraint" --If it's not in the table, make it a BallSocketConstraint
		
		local physicalConstraint: Constraint = Instance.new(constraint) --Create the constraint and parent it to the motor
		physicalConstraint.Parent = descendant.Part1
		physicalConstraint.Attachment0 = attachment0
		physicalConstraint.Attachment1 = attachment1
		
		RagdollModule.existingConstraints[character][physicalConstraint] = physicalConstraint --Log the constraint in our existing constraints table
	end
	
	RagdollModule._changeMotorsState(character, false) --Change the motors' state to false
end

function RagdollModule._setMotorsTable(character: Model) --Creates the motors table
	RagdollModule.Motors[character] = {}
	
	for i, descendant in character:GetDescendants() do
		if descendant:IsA("Motor6D") then
			RagdollModule.Motors[character][i] = descendant --For each motor, log it in the table under the character
		end
	end
end

function RagdollModule.disableRagdoll(character: Model) --Disable ragdolling for the character
	if not character or not RagdollModule.checkIfRagdolled(character) then return end --If character is nil or not ragdolled, don't run the function
	
	RagdollModule.currentlyRagdolled[character] = false --Set our state tracking of the character's ragdoll to false (not ragdolled)
	
	local humanoid = character.Humanoid
	local primaryPart = character.PrimaryPart
	
	RagdollModule.controlStates(humanoid, primaryPart, defaultWalkSpeed, defaultJumpPower, true, true) --Restore walking and jumping
	
	RagdollModule._changeHumanoidState(character, Enum.HumanoidStateType.GettingUp) --Start getting up
	RagdollModule._changeMotorsState(character, true) --Change the motors' state to true
	RagdollModule._destroyExistingConstraints(character) --Destroy the constraints to restore the walking back to normal
end

function RagdollModule.controlStates(humanoid, characterPrimaryPart, walkSpeed: number, jumpPower: number, autoRotate: boolean, headCanCollide: boolean) --Controls walking, jumping, etc.
	humanoid.WalkSpeed = walkSpeed
	humanoid.JumpPower = jumpPower
	humanoid.AutoRotate = autoRotate
	characterPrimaryPart.CanCollide = autoRotate
	humanoid.Parent.Head.CanCollide = headCanCollide
end

function RagdollModule._changeHumanoidState(character: Model, state: Enum.HumanoidStateType) --Changes the humanoid state with a few checks
	if not character then return end --If the character is nil, don't run the function
	
	local humanoid = character.Humanoid
	
	local success, error = pcall(function() --Extra security when checking for the network owner (if the network owner is nil, the server owns it and allows us to make changes on the server)
		return character.PrimaryPart:GetNetworkOwner()
	end)
	
	if not success then return end --If the pcall fails, don't continue the function

	if humanoid.Health > 0 and humanoid:GetState() ~= state then --Extra checks. If the humanoid is alive and the state is not the same as the one it already is, continue.
		humanoid:ChangeState(state)
	end
end

function RagdollModule._changeMotorsState(character: Model, state: boolean) --Changes the motors' state
	if not next(RagdollModule.Motors[character]) then return end --If the table is empty, don't run the function
	
	for _, motor in pairs(RagdollModule.Motors[character]) do
		motor.Enabled = state --Change the motors' state
	end
end

function RagdollModule._destroyExistingConstraints(character: Model) --Destroy the constraints
	if not next(RagdollModule.existingConstraints[character]) then return end --If the table is empty, don't run the function
	
	for _, constraint in pairs(RagdollModule.existingConstraints[character]) do
		constraint:Destroy() --Destroy each constraint in the table
	end
	
	table.clear(RagdollModule.existingConstraints[character]) --Clear the table to get rid of any lasting constraints
end

function RagdollModule.checkIfRagdolled(character: Model): boolean --Returns true for ragdolled, false if not ragdolled
	return RagdollModule.currentlyRagdolled[character] --Checks the state we've logged for the character and returns it.
end

return RagdollModule :: RagdollCompletions --Allows for the types at the beginning of the script to be used