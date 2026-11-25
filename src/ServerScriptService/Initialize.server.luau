local cont = script.Parent.Controllers
_G.Tickspeed = 0.125

for _, module in cont:GetChildren() do
	if module:IsA("ModuleScript") then
		local req = require(module)
        if not req then continue end
		if typeof(req) == "table" and req.Init then
			task.spawn(req.Init)
		elseif typeof(req) == "function" then
            task.spawn(req)
		end
	end
end

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")
local collectionService = game:GetService('CollectionService');
local serverStorage = game:GetService('ServerStorage');

for _, remote in pairs(ServerScriptService.Server.Remotes:GetChildren()) do
	local req = require(remote)
	if not req then
		continue
	end

	local remoteInstance: RemoteEvent = ReplicatedStorage.Remotes:FindFirstChild(remote.Name)
	if not remoteInstance then continue end
	remoteInstance.OnServerEvent:Connect(function(...)
		if typeof(req) == "table" and req.Init then
			req.Init(...)
		elseif typeof(req) == "function" then
			req(...)
		end
	end)
end

local tags = serverStorage.NotShared.Tags
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

for _, tag in tags:GetChildren() do
	init_tag(tag.Name)
end
