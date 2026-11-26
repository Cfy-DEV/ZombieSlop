return {
	Zombie = {
		Health = {
			["Max"] = 100, -- the actual zombie health!
			["Right Arm"] = 25,
			["Left Arm"] = 25,
			["Right Leg"] = 25,
			["Left Leg"] = 25,
			["Head"] = 50,
			["Torso"] = math.huge, -- infinite because killing the torso would be hit kill.
		},
        WalkSpeed = 10,
        JumpPower = 100,
	},
}
