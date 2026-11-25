const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const Guns = require(ServerStorage.NotShared.Modules.Guns)

const getMouse : RemoteFunction = ReplicatedStorage.Remotes:WaitForChild("PlayerGetMouse")
const bullet : BasePart = ReplicatedStorage.Assets.Bullet

return function(plr)
    local char : Model = plr.Character
    print(char)
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    print(tool)
    if not tool then return end
    local info = Guns[tool.Name]
    print(info)
    if not info then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    print(handle)
    local find1 = handle:FindFirstChild("ShootHere") or handle
    local mousePos = getMouse:InvokeClient(plr)
    local cloneBullet = bullet:Clone()
    cloneBullet.Parent = workspace
    cloneBullet.Anchored = true
    print(cloneBullet:GetFullName())
    local pos
    if find1:IsA("Attachment") then
        pos = find1.WorldPosition
    elseif find1:IsA("BasePart") then
        pos = find1.Position
    end
    cloneBullet.Position = pos
    local velocity = Instance.new("BodyVelocity", cloneBullet)
    velocity.MaxForce = Vector3.one*math.huge
    velocity.Velocity = CFrame.lookAt(pos, mousePos)
end