local cont = script.Parent.Controllers

print("INITIALIZED")

for _, module in cont:GetChildren() do
	if module:IsA("ModuleScript") then
		task.spawn(function()
			local err, req = pcall(function(...)
				return require(module)
			end)
			if not err then
				print(req)
				return
			elseif not req then
				return
			end
			if typeof(req) == "table" and req.Init then
				req.Init()
			elseif typeof(req) == "function" then
				req()
			end
		end)
	end
end

const Players = game:GetService("Players")
local collectionService = game:GetService('CollectionService');
local replicatedStorage = game:GetService('ReplicatedStorage');

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local tags = replicatedStorage.Shared.ClientTags
local a = {}

local function init_tag(tag: string)
	if not a[tag] then
		a[tag] = {}
	else
		return
	end
	local find1 = tags:FindFirstChild(tag)
	if find1 == nil then
		return
	end
	local tagged = collectionService:GetTagged(tag)
	for _, inst in tagged do
		a[tag][inst] = true
		local clone = find1:Clone()
		clone.Parent = inst
	end
	collectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
		if a[tag][inst] then
			return
		end
		a[tag][inst] = true
		local clone = find1:Clone()
		clone.Parent = inst
	end)
end

task.spawn(function()
	for _, tag in tags:GetChildren() do
		init_tag(tag.Name)
	end
end)

local remoteFunction: RemoteFunction = replicatedStorage.Remotes:WaitForChild("PlayerGetMouse")

remoteFunction.OnClientInvoke = function()
	return mouse.Hit.Position
end
