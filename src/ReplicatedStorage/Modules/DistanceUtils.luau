--[[
	DistanceUtil
	Fast distance checks that avoid the expensive sqrt operation.

	Usage:
		local DistanceUtil = require(game.ReplicatedStorage.DistanceUtil)

		-- Check if a player is within 10 studs of a part (no sqrt needed):
		if DistanceUtil.isWithinRange(character.HumanoidRootPart.Position, part.Position, 10) then
			-- close enough!
		end

		-- Get the squared distance (useful for custom comparisons):
		local distSq = DistanceUtil.getSquaredDistance(posA, posB)
]]

local DistanceUtil = {}

-- Returns the distance between two points SQUARED.
-- Use this when you only need to COMPARE distances, not display them.
function DistanceUtil.getSquaredDistance(a, b)
	local dx = a.X - b.X
	local dy = a.Y - b.Y
	local dz = a.Z - b.Z
	return dx * dx + dy * dy + dz * dz
end

-- Returns true if two points are within 'range' studs of each other.
-- This is the main sqrt-free check: instead of sqrt(dx² + dy² + dz²) <= range,
-- we compare dx² + dy² + dz² <= range², which is equivalent but much faster.
function DistanceUtil.isWithinRange(a, b, range)
	return DistanceUtil.getSquaredDistance(a, b) <= range * range
end

-- Returns the squared magnitude of a single vector (also sqrt-free).
function DistanceUtil.getSquaredMagnitude(v)
	return v.X * v.X + v.Y * v.Y + v.Z * v.Z
end

-- I didnt actually code this!!! just a warning that its AI.

local players = game:GetService('Players');

function DistanceUtil.getClosestPlayer(pos)
	local closest = nil
	local closestDist = math.huge
	for _, player in pairs(players:GetPlayers()) do
		local char = player.Character
		local hrs = char and char:FindFirstChild("HumanoidRootPart")
		if char and hrs then
			local dist = DistanceUtil.getSquaredDistance(hrs.Position, pos)
			if dist < closestDist then
				closest = player
				closestDist = dist
			end
		end
	end
	return closest, math.sqrt(closestDist)
end

function DistanceUtil.getPlayersInRange(pos, range)
	local playersInRange = {}
	local rangeSquared = range * range
	for _, player in pairs(players:GetPlayers()) do
		local char = player.Character
		local hrs = char and char:FindFirstChild("HumanoidRootPart")
		if hrs and DistanceUtil.getSquaredDistance(hrs.Position, pos) <= rangeSquared then
			table.insert(playersInRange, player)
		end
	end
	return playersInRange
end



return DistanceUtil